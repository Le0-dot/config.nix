# omega is a non-NixOS workstation managed by system-manager.
# During bridge phase: host declaration is commented out (legacy.nix handles output).
# Stage D: uncomment to activate den pipeline for omega.
#
# { inputs, ... }:
# {
#   den.hosts.x86_64-linux.omega = {
#     # system-manager's module system is NixOS-compatible, so we use "nixos" class
#     # but override instantiate to call makeSystemConfig instead of nixosSystem.
#     instantiate = { modules, ... }:
#       inputs.system-manager.lib.makeSystemConfig {
#         inherit modules;
#         extraSpecialArgs = { inherit inputs; };
#       };
#     intoAttr = [ "systemConfigurations" "omega" ];
#   };
# }
{ }
