{ inputs, flake, ... }:
{
  imports = [
    inputs.nix-system-graphics.systemModules.default
    flake.modules.system.hyprlock
  ];

  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
    system-graphics.enable = true;
  };
}
