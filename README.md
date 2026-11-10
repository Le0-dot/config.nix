# config.nix

Nix flake with my machine configurations, built with [den](https://github.com/denful/den).

## Structure

Every file under [`modules/`](modules) is loaded automatically (`import-tree`), so a new file needs no
registration.

### Infra

[`infra.nix`](modules/infra.nix) is the single description of everything we run. For each host it lists:

- `system` and optionally `class` (`nixos` by default, `systemManager` for non-NixOS machines),
- `users` and the classes they use,
- `disks`, by `/dev/disk/by-id` path,
- `containers`, with how each is run (`quadlet` or `oci-container`).

```nix
den.hosts.myhost = {
  system = "x86_64-linux";
  users.admin.classes = [ "user" ];
  disks.root.device = "/dev/disk/by-id/...";
  containers.web.class = "quadlet";
};
```

### Classes

| Class | Lands in |
| --- | --- |
| [`quadlet`](modules/containers/quadlet.nix) | `virtualisation.quadlet` |
| [`oci-container`](modules/containers/oci-container.nix) | `virtualisation.oci-containers.containers` |
| [`disko`](modules/disks/disko.nix) | `disko.devices.disk.<name>` |
| [`homeManager`](modules/home-manager.nix) | `home-manager.users.<user>` |

## Commands

The flake exposes per-host packages, defined in [`switch.nix`](modules/policies/switch.nix). Run them with
`nix run .#<name> -- <extra args>`:

| Package | Host class | What it does |
| --- | --- | --- |
| `switch-<host>` | all | Switch the local machine to this flake's configuration |
| `remote-switch-<host>` | all | Build and switch the host over SSH |
| `remote-install-<host>` | `nixos` | Install the host from scratch with `nixos-anywhere` |


## Deployment (GitOps)

Every deployable server has a branch named `deploy/<host>`. The branch is what the server runs:

- The [`auto-upgrade`](modules/aspects/auto-upgrade.nix) aspect points `system.autoUpgrade.flake` at
  `github:Le0-dot/config.nix?ref=deploy/<hostname>`, so a host only ever pulls its
  own branch.
- A push to `deploy/<host>` runs [`deploy.yaml`](.github/workflows/deploy.yaml). It joins the
  tailnet and starts `nixos-upgrade.service` on that host over `tailscale ssh`.

### Changing a server

1. Merge the change to `main` through a PR (`check` must pass).
2. Run the **Promote main to a host deploy branch** workflow
   ([`promote.yaml`](.github/workflows/promote.yaml)) with the `host` to update. `sha` is optional
   and defaults to the tip of `main`.
3. The workflow fast-forwards `deploy/<host>` to that commit, which triggers the
   deploy.

### Adding a host

1. Declare the host in [`infra.nix`](modules/infra.nix) and merge it to `main`.
2. Install it, either:
   - manually, or
   - with `nix run .#remote-install-<host>` (see [Commands](#commands)).
3. Create its deploy branch by hand, as a repository admin: `git push origin main:deploy/<host>`. 
4. Push triggers [`deploy.yaml`](.github/workflows/deploy.yaml), which pulls the config for the first time.

### Branch protection

- `main`: PR-only, squash merge, `check` required, linear history.
- `deploy/**`: cannot be created, updated or deleted, and cannot be force-pushed,
  except by repository admins. The promote workflow pushes with `OWNER_PAT`, which
  has that bypass. Nothing is merged into these branches through PRs.

## Automation

| Workflow       | Trigger                | What it does                                      |
| -------------- | ---------------------- | ------------------------------------------------- |
| [`check.yaml`](.github/workflows/check.yaml)   | PRs, push to `main`    | `nix fmt -- --ci` and `nix flake check` |
| [`update.yaml`](.github/workflows/update.yaml)  | Mondays, manual        | Opens a flake update PR to `main` with auto-merge |
| [`promote.yaml`](.github/workflows/promote.yaml) | manual                 | Fast-forwards `deploy/<host>` to a commit on `main` |
| [`deploy.yaml`](.github/workflows/deploy.yaml)  | push to `deploy/**`    | Starts `nixos-upgrade.service` on the host        |

