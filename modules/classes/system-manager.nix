# system-manager custom class for omega (non-NixOS host).
#
# Den has BUILT-IN support for systemManager as a host class:
#   - instantiate defaults to inputs.system-manager.lib.makeSystemConfig
#   - intoAttr defaults to [ "systemConfigs" name ]
#   - Aspects use the `systemManager` key (like `nixos` or `darwin`)
#
# Usage in modules/hosts/omega.nix:
#   den.hosts.x86_64-linux.omega.class = "systemManager";
#   den.aspects.omega.systemManager = { ... }: { ... };
#
# The only override needed: `intoAttr` to match our desired output path
# (we use "systemConfigurations" not the default "systemConfigs").
{ }
