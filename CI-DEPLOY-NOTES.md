# CI deploy: restricting the `ci` user

Notes from a working session. These are recommendations for human review, not definitive conclusions. Nothing under "Options" has been implemented or tested yet. Verify before relying on any of it.

## Goal

GitHub Actions deploys to NixOS servers (`tau` for testing, `nu`) as an unprivileged `ci` user instead of root over SSH, with `ci` restricted as much as possible. Builds already run on the target host (`--build-host`), which avoids trusted-signature problems.

## Current state

- `modules/aspects/users/ci.nix`: `ci` has `NOPASSWD` sudo for `nix-env` (the `pkgs.nix` store path), `/run/current-system/sw/bin/env` and `/bin/sh`.
- `modules/policies/switch.nix`: the local `switch-*` and `boot-*` scripts set `PATH=/run/wrappers/bin:/run/current-system/sw/bin:$PATH` before calling `nixos-rebuild`.
- `remote-switch-*` (run from another machine) already works with the rules above.

## Findings

### Local `switch-tau` failure
- `/run/current-system/sw/bin/sudo` is a plain symlink into the store, not setuid. The setuid sudo is `/run/wrappers/bin/sudo`. Over SSH, `/run/wrappers/bin` is early in PATH; under `nix run` locally it was not, so the wrong sudo could be picked. Putting `/run/wrappers/bin` first in the scripts fixes it.
- The `nix-env` in the `nix run` environment is not a different binary: nixos-rebuild-ng's wrapper prepends `nix-2.34.9`, which is the same store path as `nixosConfigurations.tau.config.nix.package`. The `/run/current-system/sw/bin/nix-env` sudo rule added during debugging was redundant and has been removed.
- nix `github:` flake refs are cached (tarball TTL, default 1h). Use `nix run --refresh github:OWNER/REPO/BRANCH#switch-tau` to pick up new commits.

### What sudo commands the tools run
Read from source (nixos-rebuild-ng 26.11 in the pinned nixpkgs, nh v4.4.2). Not run on tau.

**nixos-rebuild-ng**
- Set profile: `nix-env -p /nix/var/nix/profiles/system --set <toplevel>`
- Activate: `env -i PATH=… LOCALE_ARCHIVE=… NIXOS_NO_CHECK=… NIXOS_INSTALL_BOOTLOADER=0 systemd-run … <toplevel>/bin/switch-to-configuration <action>`
- Remote commands are wrapped as `sudo /bin/sh -c 'exec /usr/bin/env -i … "$@"' sh <cmd>`. That is why `env` and `/bin/sh` rules are needed. Sudoers cannot meaningfully restrict `env`, so `ci` is effectively root.

**nh (`--elevation-strategy passwordless`)**
- Local: `sudo env K=V… <cmd>`, so `env` is still required.
- Remote (`--target-host`), no `env` or `sh -c` wrapper:
  1. `sudo --non-interactive [NIXOS_NO_CHECK=…] <toplevel>/bin/switch-to-configuration test`
  2. `sudo --non-interactive nix build --no-link --profile /nix/var/nix/profiles/system <toplevel>`
  3. `sudo --non-interactive [NIXOS_INSTALL_BOOTLOADER=1] <toplevel>/bin/switch-to-configuration boot`
- nh does not use `systemd-run`, so an SSH drop mid-switch can interrupt activation.

### Fundamental limit of sudo-based deploys
Any user that can have root run `nix-env --set` / `switch-to-configuration` on an arbitrary store path is effectively root: any user can build derivations through the nix daemon, so a malicious `bin/switch-to-configuration` can be created. Sudoers patterns restrict command shape, not trust.

Store path matching in sudoers: the hash is 32 chars of `[0-9a-df-np-sv-z]`, so a rule can wildcard only the hash, for example `/nix/store/<32 x [0-9a-df-np-sv-z]>-nixos-system-tau-*/bin/switch-to-configuration switch`. For the command path, sudo matches per component, so `*` cannot cross `/`. In arguments `*` is looser; sudo 1.9.10+ supports `^regex$` arguments (verify). This stops accidents and other binaries, not a malicious path with the right name.

## Options (ordered roughly by security)

1. **Pull-based deploys**: hosts follow a protected branch (reviews, signed commits), build themselves and verify the commit signature before activating. Nothing outside holds a privileged login. Trust anchor becomes whoever can merge/sign.
2. **`system.autoUpgrade` + trigger the unit** (the direction we were heading):
   - `system.autoUpgrade` with `flake = "github:OWNER/REPO/<deploy-branch>"`, `flags = [ "--refresh" ]`; drop the timer (`systemd.timers.nixos-upgrade.wantedBy = lib.mkForce [ ];`, verify it takes effect).
   - `ci` only starts `nixos-upgrade.service`. Either one exact sudo rule (`/run/current-system/sw/bin/systemctl start nixos-upgrade.service`) or, with no sudo at all, a polkit rule:
     ```js
     polkit.addRule(function(action, subject) {
       if (action.id == "org.freedesktop.systemd1.manage-units" &&
           action.lookup("unit") == "nixos-upgrade.service" &&
           action.lookup("verb") == "start" &&
           subject.user == "ci") { return polkit.Result.YES; }
     });
     ```
     (set via `security.polkit.extraConfig`; test that it works over non-interactive SSH).
   - `systemctl start` on a oneshot blocks and returns the exit status; `systemctl show -p Result,ExecMainStatus nixos-upgrade.service` needs no privileges.
   - Caveats: the branch is the trust boundary; autoUpgrade has no signature verification; private repos need a read-only token available to root (agenix/sops, not the store).
3. **nh remote deploy with narrow sudo rules** (the three commands above, hash-wildcard paths). Removes `env`/`sh` but `ci` stays effectively root, and lacks `systemd-run` protection.
4. **Own root wrapper script** behind one fixed sudo command, validating the store path (pinned revision / signature) before `nix-env --set` + `switch-to-configuration`.
5. **Keep nixos-rebuild + current rules**: simplest, but `ci` is root-equivalent through `env`/`sh`.

## Journal access for the unit's logs

Checked on the dev machine (not NixOS, so tau may differ): journal files are `root:systemd-journal`, mode `0640`, with ACL entries for group `adm`. Access is per file, not per unit, so granting `ci` journal access (the `systemd-journal` group, or ACLs) exposes all system logs. Per-user journals do not cover system services.

Per-unit alternative: have `nixos-upgrade.service` also log to a dedicated file, for example `StandardOutput = "append:/var/log/nixos-upgrade.log"`, with permissions set explicitly (for example via `systemd.tmpfiles`) so `ci` can read only that file. Trade-off: output leaves the journal unless duplicated, and the log's contents should be checked for sensitive data. For now, the unit's status (`systemctl show` / the exit code of `systemctl start`) is enough.

## Open items

- Decide between options 2, 3 and 4 and implement for `tau` first.
- Verify the `--refresh` and timer-disable behaviour of `system.autoUpgrade` on the pinned nixpkgs.
- Check journal and `/var/log/journal` permissions on tau itself (read-only SSH check, not yet done).
- Decide whether to add commit-signature verification before activation.
- Decide whether to commit the `switch.nix` PATH change and the `ci.nix` comments.
