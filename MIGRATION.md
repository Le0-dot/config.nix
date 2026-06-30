# Migration Plan: blueprint -> den

Migrating from `numtide/blueprint` to `denful/den` (aspect-oriented, context-driven Nix).

## Current State

- 3 machines: `tau` (NixOS server), `omega` (non-NixOS workstation), `nu` (NixOS media server)
- `numtide/blueprint` for flake output discovery
- `home-manager` standalone on omega
- `numtide/system-manager` on omega (non-NixOS system config)
- Custom NixOS modules: `tailscale.nix`, `samba.nix`
- Custom system-manager modules: `uwsm.nix`, `hyprlock.nix`
- 22 home-manager modules in `modules/home/`
- 15 containers via `quadlet-nix` on nu
- `agenix` for secrets, `disko` for disk layout, `btr-backup` for snapshots

## Target State

All config expressed as den aspects. Custom `systemManager` den class for omega. No `hosts/` dir, no `modules/home/`, no `modules/nixos/`, no `modules/system/`, no `packages/`.

## Migration Order

**tau -> omega -> nu** (simplest first, hardest last)

---

## Stage A: Bootstrap den (everything keeps working)

### A1. Rewrite `flake.nix`

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    den.url = "github:denful/den";
    import-tree.url = "github:denful/import-tree";

    system-manager = { url = "github:numtide/system-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-system-graphics = { url = "github:soupglasses/nix-system-graphics"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    stylix = { url = "github:nix-community/stylix"; inputs.nixpkgs.follows = "nixpkgs"; };
    disko = { url = "github:nix-community/disko/latest"; inputs.nixpkgs.follows = "nixpkgs"; };
    agenix = { url = "github:ryantm/agenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    btr-backup = { url = "github:Le0-dot/btr-backup"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs.inputs = inputs;
    }).config.flake;
}
```

### A1.1. Rename existing module dirs

`import-tree` auto-imports all `.nix` files in `modules/`, but existing
`modules/{home,nixos,system}/` are NixOS/HM modules that can't be imported
into den's top-level `evalModules`. Rename with `_` prefix (import-tree skips
paths containing `/_`):

```
modules/home/   -> modules/_home/
modules/nixos/  -> modules/_nixos/
modules/system/ -> modules/_system/
```

### A1.2. Update host file imports

All `flake.homeModules.*`, `flake.nixosModules.*`, `flake.modules.system.*`
references in host configs must be replaced with direct relative path imports
to the renamed dirs:

```nix
# Before
flake.nixosModules.samba
# After
../../modules/_nixos/samba.nix
```

Also remove `flake` from module function arguments where no longer needed.

### A2. Create `modules/den.nix`

> **Important:** Do NOT declare `den.homes` during the bridge phase. Den's
> pipeline auto-generates `homeConfigurations` from `den.homes`, which
> conflicts with the manually-built entry in `legacy.nix`. Add `den.homes`
> only after the legacy bridge for that home is removed (Stage D).

```nix
{ inputs, den, lib, ... }: {
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.hosts.x86_64-linux.tau = { };
  den.hosts.x86_64-linux.nu = { };

  # omega is NOT declared as den.hosts (not NixOS) and NOT as den.homes
  # (would conflict with legacy.nix bridge). Added in Stage D.

  den.default.includes = [
    den.batteries.hostname
    den.batteries.define-user
  ];
}
```

### A3. Create `modules/flake-outputs.nix`

Wire devShells and formatter into den's `flake.*` output:

```nix
{ inputs, lib, ... }:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in {
  flake.devShells.${system}.default = pkgs.mkShell {
    packages = [
      pkgs.nil
      pkgs.gnumake
      (inputs.agenix.packages.${system}.default)
    ];
  };

  flake.formatter.${system} = pkgs.treefmt.withConfig {
    runtimeInputs = [ pkgs.nixfmt pkgs.deadnix pkgs.keep-sorted ];
    settings = {
      on-unmatched = "info";
      tree-root-file = "flake.nix";
      formatter = {
        nixfmt = { command = "nixfmt"; includes = [ "*.nix" ]; };
        deadnix = {
          command = "deadnix";
          options = [ "--edit" "--no-lambda-arg" "--no-lambda-pattern-names" ];
          includes = [ "*.nix" ];
        };
        keep-sorted = { command = "keep-sorted"; includes = [ "*" ]; };
      };
    };
  };
}
```

### A4. Create `modules/legacy.nix` (temporary bridge)

Manually constructs flake outputs from existing host configs. Replicates
blueprint's `specialArgs` (`flake.lib`, `perSystem.self`, `hostName`).

> **Important:** `home-manager.lib.homeManagerConfiguration` requires explicit
> `home.username`, `home.homeDirectory`, and `home.stateVersion`. Blueprint set
> these automatically from filesystem conventions. The bridge must set them in
> an inline module. Also, `pkgs` must be imported with `config.allowUnfree = true`
> (passing `nixpkgs.config.allowUnfree` inside modules causes infinite recursion
> when `pkgs` is also provided).

```nix
{ inputs, ... }:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  customLib = import ../lib/default.nix { };
  flake = { lib = customLib; };
  perSystem = {
    self = {
      choose-repo = import ../packages/choose-repo.nix { inherit pkgs; };
      clipselect = import ../packages/clipselect.nix { inherit pkgs; };
      hyprlock = import ../packages/hyprlock.nix { inherit pkgs; };
      hyprpaper = import ../packages/hyprpaper.nix { inherit pkgs; };
    };
  };
in {
  flake.nixosConfigurations.tau = inputs.nixpkgs.lib.nixosSystem {
    modules = [ ../hosts/tau/configuration.nix ];
    specialArgs = { inherit inputs flake; hostName = "tau"; };
  };

  flake.nixosConfigurations.nu = inputs.nixpkgs.lib.nixosSystem {
    modules = [ ../hosts/nu/configuration.nix ];
    specialArgs = { inherit inputs flake; hostName = "nu"; };
  };

  flake.systemConfigurations.omega = inputs.system-manager.lib.makeSystemConfig {
    modules = [ ../hosts/omega/system-configuration.nix ];
    extraSpecialArgs = { inherit inputs; };
  };

  flake.homeConfigurations."lev.koliadich@omega" =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [
        ../hosts/omega/users/lev.koliadich.nix
        {
          home.username = "lev.koliadich";
          home.homeDirectory = "/home/lev.koliadich";
          home.stateVersion = "26.05";
        }
      ];
      extraSpecialArgs = { inherit inputs perSystem; };
    };
}
```

### A5. Update flake.lock

```
nix flake lock
```

**Checkpoint:** All configs evaluate correctly:
```
nix eval .#nixosConfigurations.tau.config.networking.hostName   # "tau"
nix eval .#nixosConfigurations.nu.config.networking.hostName    # "nu"
nix eval '.#homeConfigurations."lev.koliadich@omega".config.home.stateVersion'  # "26.05"
```

---

## Stage B: system-manager custom class

### B1. Create `modules/classes/system-manager.nix`

system-manager uses `system-manager.lib.makeSystemConfig { modules = [...]; }` to produce `systemConfigs.<name>`. The output goes to `flake.systemConfigurations.<name>`.

The custom class approach:
- Aspects define config under a `systemManager` key
- A custom policy resolves this key and produces `flake.systemConfigurations`
- Uses `den.batteries.forward` to wire the class into the host

```nix
{ den, inputs, lib, ... }:
let
  # Only omega has system-manager; guard on host having the class
  omega = den.den.hosts.x86_64-linux.omega;

  # Resolve all systemManager modules from omega's aspect tree
  systemManagerModules = den.lib.aspects.resolve "systemManager" (
    den.aspects.${omega.aspect} { host = omega; }
  );
in {
  # Register systemManager as a known class on omega
  den.hosts.x86_64-linux.omega.class = "systemManager";

  # Produce the flake output
  flake.systemConfigurations.omega = inputs.system-manager.lib.makeSystemConfig {
    modules = [ systemManagerModules ];
  };
}
```

> **Important:** The exact API for `den.lib.aspects.resolve` needs validation against
> den's current version. An alternative approach is to use the `From Flake to Den`
> pattern where `omega.mainModule` collects all resolved config for that host, and we
> pass it directly to `makeSystemConfig`.
>
> Simpler fallback if `resolve` doesn't work for custom classes:
> ```nix
> flake.systemConfigurations.omega = inputs.system-manager.lib.makeSystemConfig {
>   modules = [
>     omega.mainModule  # den resolves systemManager class into this
>   ];
> };
> ```

### B2. Alternative: `den.batteries.forward` approach

If omega also has NixOS-like hosts, use forward. But since omega is purely
system-manager (no nixos/darwin), the direct `makeSystemConfig` + `mainModule`
approach is simpler. The forward battery is designed for routing a class *into*
another class — here there's no parent NixOS to route into.

**Decision: use the `mainModule` approach.** omega's host class is `"systemManager"`,
and den resolves aspects into `omega.mainModule`, which we feed to `makeSystemConfig`.

---

## Stage C: Migrate tau (NixOS server, simplest host)

### C1. `modules/aspects/server-base.nix`

Shared NixOS server config extracted from both tau and nu:

```nix
{ den, ... }: {
  den.aspects.server-base = {
    includes = [ den.batteries.hostname ];
    nixos = { ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.gc.automatic = true;
      system.stateVersion = "25.05";
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot = { enable = true; configurationLimit = 10; };
      services.openssh.enable = true;
      users = {
        mutableUsers = false;
        users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWPb8bgtgpMQw1+TQElFUaGFy8YL6r1aRUZWCMXsu4q"
        ];
      };
    };
  };
}
```

### C2. `modules/aspects/tailscale.nix`

Wraps the existing NixOS module (option declarations + auto-generated systemd units from pod labels):

```nix
{ den, ... }: {
  den.aspects.tailscale = {
    nixos = ./nixos-modules/tailscale.nix;  # the existing module, moved here
  };
}
```

### C3. `modules/aspects/samba.nix`

Same pattern:

```nix
{ den, ... }: {
  den.aspects.samba = {
    nixos = ./nixos-modules/samba.nix;
  };
}
```

### C4. `modules/aspects/tau.nix`

```nix
{ den, inputs, ... }: {
  den.aspects.tau = {
    includes = [
      den.aspects.server-base
      den.aspects.tailscale
      den.aspects.samba
    ];
    nixos = { config, pkgs, ... }: {
      imports = [
        inputs.disko.nixosModules.disko
        inputs.agenix.nixosModules.default
        inputs.quadlet-nix.nixosModules.quadlet
        ./hardware/tau-hardware.nix
        ./hardware/tau-disk.nix
        ./secrets/tau.nix
      ];

      services.tailscale = {
        enable = true;
        authKeyFile = config.age.secrets.tailscale-key.path;
        authKeyParameters.ephemeral = false;
        extraUpFlags = [ "--advertise-tags=tag:nix" "--ssh" "--accept-routes" ];
        services.enable = true;
      };

      services.samba = {
        enable = true;
        users = [ rec { name = "le0"; password-file = config.age.secrets."${name}-password".path; } ];
        settings."public" = {
          "path" = "/tmp"; "public" = "no"; "browseable" = "yes";
          "read only" = "yes"; "force user" = "root";
        };
      };

      services.garage = { /* ... */ };
      services.yggdrasil = { /* ... */ };
      # etc — full tau-specific config
    };
  };
}
```

### C5. Remove tau from `modules/legacy.nix`

Delete the `flake.nixosConfigurations.tau` bridge entry. Now den produces it from the aspect.

**Checkpoint:** `nix build .#nixosConfigurations.tau.config.system.build.toplevel`

---

## Stage D: Migrate omega (system-manager + standalone home)

### D1. `modules/aspects/omega.nix`

```nix
{ den, inputs, ... }: {
  den.aspects.omega = {
    systemManager = { pkgs, ... }: {
      imports = [ inputs.nix-system-graphics.systemModules.default ];

      nixpkgs.hostPlatform = "x86_64-linux";
      system-graphics.enable = true;

      # UWSM module (moved from modules/system/uwsm.nix)
      programs.uwsm.enable = true;

      # hyprlock PAM (moved from modules/system/hyprlock.nix)
      environment.etc."pam.d/hyprlock".text = ''
        auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so max_tries=3
        auth sufficient ${pkgs.sssd}/lib/security/pam_sss.so try_first_pass
        auth required ${pkgs.linux-pam}/lib/security/pam_deny.so
      '';
    };
  };
}
```

> The UWSM module with its custom options will be inlined or imported as a file.

### D2. Home aspects (merged groupings)

Each is an independent aspect file under `modules/aspects/users/`:

| File | Merges from | Key content |
|------|-------------|-------------|
| `git.nix` | `modules/home/git.nix` | git settings + delta + lazygit |
| `zsh.nix` | `modules/home/zsh.nix` | zsh plugins, initContent (NOT enable — battery handles that) |
| `neovim.nix` | `modules/home/neovim.nix` | custom `config` option, tree-sitter, out-of-store symlink |
| `hyprland.nix` | `hyprland.nix` + `wm-common.nix` + `hyprlock.nix` + `hypridle.nix` + `hyprpaper.nix` | Full Wayland WM stack; inlines `choose-repo`, `clipselect`, `hyprlock`, `hyprpaper` packages |
| `waybar.nix` | `modules/home/waybar.nix` | Bar config |
| `desktop-utils.nix` | `cliphist.nix` + `tofi.nix` + `wlogout.nix` + `dunst.nix` + `playerctl.nix` | Small WM utility services |
| `terminal.nix` | `ghostty.nix` + `starship.nix` + `atuin.nix` | Terminal emulator + prompt + history |
| `kanshi.nix` | `modules/home/kanshi.nix` | Output management |
| `television.nix` | `modules/home/television.nix` | File picker |

Example — `modules/aspects/users/terminal.nix`:

```nix
{ den, ... }: {
  den.aspects.terminal = {
    homeManager = { pkgs, lib, config, ... }: {
      # ghostty
      stylix.targets.ghostty.enable = true;
      programs.ghostty = { /* settings from ghostty.nix */ };

      # starship
      programs.starship = { /* settings from starship.nix */ };

      # atuin
      programs.atuin = { /* settings from atuin.nix */ };
    };
  };
}
```

### D3. `modules/aspects/users/lev.koliadich.nix`

```nix
{ den, inputs, ... }: {
  den.aspects."lev.koliadich" = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")

      den.aspects.git
      den.aspects.zsh
      den.aspects.neovim
      den.aspects.hyprland
      den.aspects.waybar
      den.aspects.desktop-utils
      den.aspects.terminal
      den.aspects.kanshi
      den.aspects.television
    ];

    homeManager = { pkgs, config, inputs, ... }: {
      imports = [
        inputs.stylix.homeModules.stylix
        inputs.agenix.homeManagerModules.default
      ];

      home.stateVersion = "26.05";
      home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
      home.shellAliases.cat = "bat -p";
      nix.gc.automatic = true;

      stylix = {
        enable = true;
        autoEnable = false;
        targets = { gtk.enable = true; font-packages.enable = true; fontconfig.enable = true; };
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
        fonts = { /* ... */ };
      };

      # zsh loginExtra/envExtra (omega-specific shell startup)
      programs.zsh = {
        envExtra = ''
          if [ -e /etc/profile.d/system-manager-path.sh ]; then
            . /etc/profile.d/system-manager-path.sh
          fi
        '';
        loginExtra = ''
          if uwsm check may-start && uwsm select; then
            exec uwsm start default
          fi
        '';
      };

      # Simple enables (no extra config needed)
      programs.fzf.enable = true;
      programs.direnv.enable = true;
      programs.lazygit.enable = true;
      programs.fd.enable = true;
      programs.ripgrep.enable = true;
      programs.uv.enable = true;
      programs.ty.enable = true;
      programs.npm.enable = true;
      programs.opencode.enable = true;
      programs.claude-code.enable = true;
      stylix.targets.bat.enable = true;
      programs.bat.enable = true;
      programs.eza = { enable = true; colors = "always"; icons = "auto"; };
      programs.gh.enable = true;
      services.hyprpolkitagent.enable = true;
      programs.hyprshot.enable = true;
    };
  };
}
```

### D4. Remove omega from `modules/legacy.nix`

**Checkpoint:** `nix build .#homeConfigurations."lev.koliadich@omega".activationPackage`
and `nix build .#systemConfigurations.omega.config.build.toplevel` (or however system-manager exposes it).

---

## Stage E: Migrate nu (NixOS media server, most complex)

### E1. Container aspects

Each container file moves to `modules/aspects/containers/<name>.nix`. Content is identical except wrapped in an aspect:

```nix
# modules/aspects/containers/jellyfin.nix
{ den, ... }: {
  den.aspects.jellyfin = {
    nixos = { config, lib, ... }:
    let
      btrfsVolume = lib.btrfsVolume config.disko;  # from specialArgs or lib
      mountVolume = lib.mountVolume;
    in {
      virtualisation.quadlet = { /* ... existing content ... */ };
    };
  };
}
```

> `lib.btrfsVolume` / `lib.mountVolume` need to be available. Either pass via
> `specialArgs` in den's module evaluation, or import `../../lib` in the aspect.

All 15 containers: `jellyfin`, `immich`, `paperless-ngx`, `adguardhome`, `komga`,
`audiobookshelf`, `transmission`, `prowlarr`, `radarr`, `sonarr`, `jellyseerr`,
`homeassistant`, `baikal`, `bentopdf`, `ntfy`.

### E2. `modules/aspects/backup.nix`

Move `hosts/nu/backup.nix` into an aspect:

```nix
{ den, ... }: {
  den.aspects.backup = {
    nixos = { pkgs, config, ... }: { /* existing backup.nix content */ };
  };
}
```

### E3. `modules/aspects/nu.nix`

```nix
{ den, inputs, ... }: {
  den.aspects.nu = {
    includes = [
      den.aspects.server-base
      den.aspects.tailscale
      den.aspects.samba
      den.aspects.backup
      # All 15 containers
      den.aspects.jellyfin
      den.aspects.immich
      den.aspects.paperless-ngx
      den.aspects.adguardhome
      den.aspects.komga
      den.aspects.audiobookshelf
      den.aspects.transmission
      den.aspects.prowlarr
      den.aspects.radarr
      den.aspects.sonarr
      den.aspects.jellyseerr
      den.aspects.homeassistant
      den.aspects.baikal
      den.aspects.bentopdf
      den.aspects.ntfy
    ];
    nixos = { config, pkgs, ... }: {
      imports = [
        inputs.disko.nixosModules.disko
        inputs.agenix.nixosModules.default
        inputs.quadlet-nix.nixosModules.quadlet
        inputs.btr-backup.nixosModules.btr-backup
        ./hardware/nu-hardware.nix
        ./hardware/nu-disk.nix
        ./secrets/nu.nix
      ];

      environment.systemPackages = [ pkgs.neovim pkgs.curl pkgs.jq ];

      services.tailscale = {
        enable = true;
        authKeyFile = config.age.secrets.tailscale-key.path;
        authKeyParameters.ephemeral = false;
        extraUpFlags = [ "--advertise-tags=tag:nix" "--ssh" ];
        services.enable = true;
      };
    };
  };
}
```

### E4. Remove nu from `modules/legacy.nix`

**Checkpoint:** `nix build .#nixosConfigurations.nu.config.system.build.toplevel`

---

## Stage F: Cleanup

- Delete `modules/legacy.nix`
- Delete `hosts/` directory
- Delete `modules/home/`, `modules/nixos/`, `modules/system/`
- Delete `packages/` directory
- Delete `devshell.nix`, `formatter.nix` (moved into `modules/flake-outputs.nix`)
- Update `Makefile` to use new flake output paths
- Run `nix flake check`
- Rebuild all three hosts to confirm

---

## Batteries Used

| Battery | Replaces | Applied where |
|---------|----------|---------------|
| `den.batteries.hostname` | Manual `networking.hostName = hostName;` | `den.default.includes` or `server-base` |
| `den.batteries.define-user` | Manual `users.users.<name>.isNormalUser` | `den.default.includes` |
| `den.batteries.primary-user` | Manual `extraGroups = ["wheel"]` | `lev.koliadich` aspect |
| `den.batteries.user-shell "zsh"` | Manual `programs.zsh.enable` + OS shell | `lev.koliadich` aspect |
| `den.batteries.home-manager` | (auto-activated) HM integration | Auto when user has `homeManager` class |
| `den.batteries.unfree` | Global `allowUnfree = true` | Host aspects or `den.default` |
| `den.batteries.import-tree` | Bridge during migration only | `modules/legacy.nix` (temporary) |
| `den.batteries.forward` | Custom class wiring | `system-manager` class |

---

## system-manager Class: Design Notes

### Why a custom class is needed

omega runs on a non-NixOS distro. It has no `nixos` or `darwin` class. Den's
built-in pipeline only knows `nixos`, `darwin`, `homeManager`, `hjem`, `maid`.
system-manager is a separate module system with its own `evalModules`.

### Architecture

```
den.hosts.x86_64-linux.omega
  ├── class = "systemManager"     # host's primary class
  ├── aspect = "omega"            # den.aspects.omega
  └── users."lev.koliadich"
        └── classes = [ "homeManager" ]  # standalone HM via den.homes
```

### How it produces output

Den resolves `omega.mainModule` by collecting all `systemManager` class content
from the omega aspect tree. This module is then passed to:

```nix
flake.systemConfigurations.omega = inputs.system-manager.lib.makeSystemConfig {
  modules = [ omega.mainModule ];
};
```

### Standalone home-manager for omega

Since omega has no NixOS/Darwin, HM can't be integrated via the OS-level
`home-manager.users.*` pattern. Instead, use `den.homes`:

```nix
den.homes.x86_64-linux."lev.koliadich@omega" = {};
```

This produces `flake.homeConfigurations."lev.koliadich@omega"` — a standalone
home-manager configuration activated via `home-manager switch`.

### Open question for implementation

Den's pipeline assumes hosts have a class from `{nixos, darwin}` for the built-in
`host-to-users` policy to fire. With a custom `systemManager` class, we may need
to register the class explicitly:

```nix
den.classes.systemManager = {};
```

Or override the host's class resolution. This needs testing against den's actual
implementation. If the pipeline doesn't resolve `systemManager` content into
`mainModule` out of the box, we fall back to manually calling `den.lib.aspects.resolve`:

```nix
flake.systemConfigurations.omega = inputs.system-manager.lib.makeSystemConfig {
  modules = [
    (den.lib.aspects.resolve "systemManager"
      (den.aspects.omega { host = den.den.hosts.x86_64-linux.omega; }))
  ];
};
```

---

## Files to create (final state)

```
modules/
├── den.nix
├── flake-outputs.nix
├── classes/
│   └── system-manager.nix
├── aspects/
│   ├── server-base.nix
│   ├── tailscale.nix
│   ├── samba.nix
│   ├── backup.nix
│   ├── nu.nix
│   ├── tau.nix
│   ├── omega.nix
│   ├── nixos-modules/
│   │   ├── tailscale.nix      # existing module content (option declarations)
│   │   └── samba.nix          # existing module content (option declarations)
│   ├── containers/
│   │   ├── jellyfin.nix
│   │   ├── immich.nix
│   │   ├── paperless-ngx.nix
│   │   ├── adguardhome.nix
│   │   ├── komga.nix
│   │   ├── audiobookshelf.nix
│   │   ├── transmission.nix
│   │   ├── prowlarr.nix
│   │   ├── radarr.nix
│   │   ├── sonarr.nix
│   │   ├── jellyseerr.nix
│   │   ├── homeassistant.nix
│   │   ├── baikal.nix
│   │   ├── bentopdf.nix
│   │   └── ntfy.nix
│   └── users/
│       ├── lev.koliadich.nix
│       ├── git.nix
│       ├── zsh.nix
│       ├── neovim.nix
│       ├── hyprland.nix
│       ├── waybar.nix
│       ├── desktop-utils.nix
│       ├── terminal.nix
│       ├── kanshi.nix
│       └── television.nix
├── hardware/
│   ├── nu-hardware.nix
│   ├── nu-disk.nix
│   ├── tau-hardware.nix
│   └── tau-disk.nix
└── secrets/
    ├── nu.nix
    └── tau.nix
```

## Files to delete (after full migration)

- `hosts/` (entire directory)
- `modules/home/` (entire directory)
- `modules/nixos/` (entire directory)
- `modules/system/` (entire directory)
- `packages/` (entire directory)
- `devshell.nix` (moved into modules/flake-outputs.nix)
- `formatter.nix` (moved into modules/flake-outputs.nix)
- `modules/legacy.nix` (temporary bridge, removed last)
