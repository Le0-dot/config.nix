{ lib, ... }:

{
  imports = [
    ./hyprland.nix
  ];

  options.default.wm = lib.mkOption {
    type = lib.types.str;
    description = "Default window manager";
  };
}
