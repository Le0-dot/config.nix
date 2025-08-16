{ lib, ... }:

{
  imports = [ ./fuzzel.nix ];

  options.default.runner = lib.mkOption {
    type = lib.types.str;
    description = "Default runner command";
  };
}
