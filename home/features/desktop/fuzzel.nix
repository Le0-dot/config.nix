{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.features.desktop.fuzzel = lib.mkEnableOption "fuzzel";

  config = lib.mkIf config.features.desktop.fuzzel {
    stylix.targets.fuzzel.enable = true;

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          use-bold = true;
          prompt = ''"❯   "'';
          show-actions = "yes";
          width = 50;
          line-height = 18;
        };
        border.radius = 20;
      };
    };

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
          "SHIFT"
        ];
        key = "RETURN";
        action = "fuzzel";
      }
      {
        modifiers = [
          "SUPER"
          "CTRL"
        ];
        key = "V";
        action = "clipselect";
      }
    ];
  };
}
