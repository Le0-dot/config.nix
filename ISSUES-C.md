# Stage C Issues

Issues encountered during execution of Stage C (migrate tau).

## 1. samba.nix uses `hostName` from blueprint's specialArgs

**Symptom:** `modules/_nixos/samba.nix` has `hostName` in its function arguments,
which was injected by blueprint's `specialArgs`. Den doesn't provide this.

**Root cause:** Blueprint auto-injected `hostName` into every module's specialArgs.
Den uses `den.batteries.hostname` to set `networking.hostName` from the host key,
but doesn't inject a standalone `hostName` arg.

**Solution:** Replace `hostName` in samba.nix function args with
`config.networking.hostName` (which den.batteries.hostname sets). Removed
`hostName` from the function args entirely.

## 2. Relative path from aspect nixos class to _nixos modules

**Symptom:** Initially wrote `../modules/_nixos/tailscale.nix` in the aspect.

**Root cause:** Aspect files live at `modules/aspects/tailscale.nix`. Relative
path to `modules/_nixos/tailscale.nix` is `../_nixos/tailscale.nix` (one level
up from `aspects/` to `modules/`, then into `_nixos/`).

**Solution:** Use `../_nixos/tailscale.nix` as the path in aspect nixos values.

## 3. secrets.nix relative paths still work from new location

**Non-issue:** `modules/_secrets/tau.nix` references `../../secrets/*.age`.
From `modules/_secrets/`, going up two levels reaches the repo root where
`secrets/` lives. Path is correct without modification.
