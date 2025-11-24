{ pkgs, perSystem, ... }:

pkgs.mkShell {
  packages = [
    pkgs.nil
    pkgs.gnumake
    pkgs.home-manager
    pkgs.nixos-rebuild
    perSystem.agenix.default
  ];
}
