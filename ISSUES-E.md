# Stage E Issues

Issues encountered during execution of Stage E (migrate nu).

## 1. Container modules need flake.lib from specialArgs

**Symptom:** Container files reference `flake.lib.btrfsVolume` and
`flake.lib.mountVolume` which were provided by blueprint's specialArgs.

**Root cause:** Blueprint injected `flake = { lib = customLib; }` into
specialArgs for all host modules. The container files destructure `flake`
from their function args.

**Solution:** Set `_module.args.flake = { lib = customLib; }` in the nu
aspect's nixos module. This makes `flake` available as a module arg to all
imported modules (containers, backup) without changing their code.

## 2. Container/backup files left at original location

**Non-issue for now:** Container and backup files are imported via relative
paths from `hosts/nu/`. Moving them to `modules/aspects/containers/` is
deferred to Stage F cleanup. The aspect imports work from their current
location.

## 3. samba.nix hostName fix applied in Stage C works for nu too

**Non-issue:** The fix from Stage C (replacing `hostName` function arg with
`config.networking.hostName`) applies to nu as well since both hosts import
the same `_nixos/samba.nix`. No additional changes needed.
