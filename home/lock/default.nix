{ lib, ... }:

{
  imports = [ ./hyprlock.nix ];

  options.default.lock = lib.mkOption {
    type = lib.types.str;
    description = "Default lock command";
  };
}
