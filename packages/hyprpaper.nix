{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "hyprpaper";
  runtimeInputs = [
    pkgs.hyprpaper
  ];
  text = ''
    export LD_PRELOAD="${pkgs.sssd}/lib/libnss_sss.so.2"
    hyprpaper "$@"
  '';
}
