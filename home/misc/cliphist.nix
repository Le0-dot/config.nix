{ pkgs, ... }:

{
  services.cliphist.enable = true;

  home.packages = [
    pkgs.wl-clipboard-rs
    (pkgs.writeShellScriptBin "clipselect" ''
      #!/usr/bin/env sh

      cliphist list \
        | fuzzel --dmenu --with-nth 2 --accept-nth 1 \
        | tr -d '\n' \
        | cliphist decode \
        | wl-copy
    '')
  ];

  keybind.binds = [
    {
      modifiers = [
        "SUPER"
        "CTRL"
      ];
      key = "V";
      action = "clipselect";
    }
  ];
}
