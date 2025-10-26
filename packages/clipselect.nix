{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "clipselect";
  runtimeInputs = [
    pkgs.cliphist
    pkgs.wl-clipboard-rs
    pkgs.gawk
  ];
  text = ''
    [ -z "$1" ] && echo "Set dmenu program via first program argument" && exit 1

    dmenu="$1"

    hist=$(cliphist list)

    choice=$(echo "$hist" | awk 'BEGIN { FS="\t" } { print $2 }' | "$dmenu")
    echo "$hist" | awk -v entry="$choice" 'BEGIN { FS="\t" } $2 == entry { printf "%d", $1; exit 0 }' | cliphist decode | wl-copy
  '';
}
