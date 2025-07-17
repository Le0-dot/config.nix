{ lib, ... }:

{
  imports = [
    ./waybar.nix
  ];

  options.default.bar = lib.mkOption {
    type = lib.types.str;
    description = "Default bar command";
  };
}
