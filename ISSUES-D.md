# Stage D Issues

Issues encountered during execution of Stage D (migrate omega).

## 1. den.batteries.hostname fails on system-manager host

**Symptom:** `The option 'networking.hostName' does not exist` when evaluating
omega's system-manager configuration.

**Root cause:** `den.default.includes` contains `den.batteries.hostname`, which
sets `networking.hostName` in the `nixos` class. For omega, the `nixos` class
routes to system-manager, which has no `networking.hostName` option.

**Solution:** Add `excludes = [ den.batteries.hostname ]` to the omega aspect.
System-manager doesn't need hostname management.

## 2. den.default.nixos.system.stateVersion fails on system-manager

**Symptom:** `The option 'system.stateVersion' does not exist` when evaluating
omega's configuration.

**Root cause:** `den.default.nixos.system.stateVersion` applies to ALL hosts'
`nixos` class. omega's `nixos` class feeds system-manager which doesn't have
this option.

**Solution:** Moved `system.stateVersion` from `den.default.nixos` into the
`server-base` aspect (only real NixOS hosts include it). `den.default` now
only sets `homeManager.home.stateVersion`.

## 3. perSystem.self.* not available in den standalone homes

**Symptom:** `_home/` modules reference `perSystem.self.clipselect` etc. which
was passed via `extraSpecialArgs` in the legacy bridge.

**Root cause:** Den's standalone home pipeline doesn't expose a mechanism to
inject custom specialArgs. The `homeManager` class content is a plain module.

**Solution:** Set `_module.args.perSystem` inside the homeManager module with
inline package imports. This provides the same `perSystem.self.*` attrset
the `_home/` modules expect.

## 4. system-manager uses `specialArgs` not `extraSpecialArgs`

**Symptom:** Deprecation warning: "extraSpecialArgs is deprecated and will be
removed in the next release, please use specialArgs instead"

**Root cause:** system-manager has renamed `extraSpecialArgs` to `specialArgs`.

**Solution:** Changed `extraSpecialArgs` to `specialArgs` in the `instantiate`
override.
