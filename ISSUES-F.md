# Stage F Issues

Issues encountered during execution of Stage F (cleanup).

## 1. Cannot fully delete hosts/ — container files still imported

**Symptom:** nu aspect imports containers from `../../hosts/nu/containers/*.nix`
and `../../hosts/nu/backup.nix`.

**Root cause:** Rewriting 15 container files + backup.nix as proper den aspects
is a large change. Deferring to avoid scope creep in this migration.

**Solution:** Leave `hosts/nu/` in place for now. A future pass will either:
- Move containers to `modules/aspects/containers/` as individual aspect files
- Or inline them directly into the nu aspect

## 2. Cannot delete packages/ or lib/ — still referenced

**Symptom:** User aspect provides `_module.args.perSystem` pointing to
`../../packages/*.nix`, and nu aspect provides `_module.args.flake` pointing
to `../../lib/default.nix`.

**Root cause:** The `_home/` modules and container modules still expect these
args. Changing them requires touching 4+ HM modules and 14 container modules.

**Solution:** Deferred. These directories stay until the modules are rewritten
to not depend on the legacy arg patterns.

## 3. Makefile hosts/ check simplified

**Non-issue:** The old `host :=` line checked if `$PWD/hosts/$HOST` existed.
Replaced with simple `$(or $(HOST),omega)` — the hosts/ dir check was just
a fallback to omega, not a validation.
