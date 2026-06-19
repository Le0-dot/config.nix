{ pkgs, perSystem, ... }:

pkgs.mkShell {
  packages = [
    pkgs.nil
    pkgs.gnumake
    perSystem.agenix.default
  ];
}
