# Stage B Issues

Issues encountered during execution of Stage B (system-manager custom class).

## 1. `forward` battery is wrong tool for standalone module systems

**Symptom:** Original plan used `den.batteries.forward` to wire system-manager.

**Root cause:** `forward` routes content FROM one class INTO a target submodule
path on another class. system-manager has no parent class — it's a standalone
`evalModules` call (like standalone home-manager). There's nothing to route into.

**Solution:** Use den's `host.instantiate` override instead. system-manager's
module system is NixOS-module-compatible, so the aspect's `nixos` class content
feeds directly into `makeSystemConfig`. Override `intoAttr` to produce
`flake.systemConfigurations.omega`.

## 2. `den.lib.aspects.resolve` is internal API

**Symptom:** Original plan relied on `den.lib.aspects.resolve "systemManager" ...`
to extract custom class content.

**Root cause:** `den.lib.aspects.resolve` is documented as **Internal** in the
den.lib reference. Its signature takes `class aspect` where `aspect` is a resolved
entity record — not a simple function call like `den.aspects.omega { host = ... }`.

**Solution:** Not needed. By using the `nixos` class (which system-manager modules
are compatible with), den's standard host resolution pipeline produces `mainModule`
automatically. The custom `instantiate` function receives it.

## 3. `den.den.hosts` doesn't exist as expected

**Symptom:** `den.den.hosts.x86_64-linux.omega` was referenced in the class module.

**Root cause:** `den.den` is not a documented public API. The resolved host entities
are accessed through `den.hosts` at the module args level, not `den.den.hosts`.

**Solution:** Not needed with the `instantiate` approach — den handles resolution
internally and passes modules to `instantiate`.
