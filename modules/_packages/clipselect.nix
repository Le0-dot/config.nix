{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "clipselect";
  runtimeInputs = [
    pkgs.cliphist
    pkgs.wl-clipboard-rs
  ];
  text = ''
    [ -z "$1" ] && echo "Set dmenu program via first program argument" && exit 1

    dmenu="$1"

    cliphist list | "$dmenu" | cliphist decode | wl-copy
  '';
}
