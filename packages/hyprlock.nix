{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "hyprlock";
  runtimeInputs = [ pkgs.hyprlock ];
  text = ''exec env LD_PRELOAD="${pkgs.sssd}/lib/libnss_sss.so.2" hyprlock "$@"'';
}
