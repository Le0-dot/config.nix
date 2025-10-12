{ pkgs, ... }:

pkgs.mkShell {
  packages = [
    pkgs.nil
    pkgs.gnumake
  ];
}
