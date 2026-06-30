{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "choose-repo";
  runtimeInputs = [
    pkgs.fd
    pkgs.git
    pkgs.gawk
  ];
  text = ''
    [ -z "$1" ] && echo "Set dmenu program via first program argument" && exit 1
    [ -z "$2" ] && echo "Set search directory via second program argument" && exit 1
    [ -z "$3" ] && echo "Set search depth via third program argument" && exit 1

    dmenu="$1"
    dir="$2"
    depth="$3"

    repos=$(fd --hidden --max-depth "$depth" --glob '**/.git' "$dir" --exec echo '{//}')

    choice=$(echo "$repos" | awk 'BEGIN { FS="/" } { print $NF }' | "$dmenu")
    echo "$repos" | awk -v dir="$choice" 'BEGIN { FS="/" } $NF == dir { print $0 }'
  '';
}
