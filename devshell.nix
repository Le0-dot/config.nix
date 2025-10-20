{ pkgs, perSystem, ... }:

pkgs.mkShell {
  packages = [
    pkgs.nil
    pkgs.nixos-rebuild
    pkgs.gnumake
    perSystem.agenix.default
  ];
}
