{ lib, ... }:

{
  options.default.powermenu = lib.mkOption {
    type = lib.types.str;
    description = "Default powermenu application";
  };

  imports = [ ./wlogout.nix ];
}
