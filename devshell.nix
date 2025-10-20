{ pkgs, ... }:

pkgs.mkShell {
  packages = [
    pkgs.nil
    pkgs.nixos-rebuild
    pkgs.gnumake
    pkgs.jq
  ];
}
