{ inputs, flake, ... }:
{
  imports = [
    inputs.nix-system-graphics.systemModules.default
  ];

  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
    system-graphics.enable = true;
  };
}
