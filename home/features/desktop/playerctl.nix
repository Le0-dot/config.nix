{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.features.desktop.playerctl = lib.mkEnableOption "playerctl";

  config = lib.mkIf config.features.desktop.playerctl {
    services.playerctld.enable = true;

    home.packages = [
      (pkgs.writeShellApplication {
        name = "playerctl-save";
        runtimeInputs = [
          pkgs.playerctl
          pkgs.gnused
        ];
        text = ''
          file=$HOME/.player

          function status() {
              playerctl -a metadata -f '{{ playerName }} {{ status }}'
          }

          function status-to-script() {
              sed '/Paused/d; /Stopped/d; s/^\(.\+\) Playing/playerctl -p \1 play/'
          }

          status | status-to-script > "$file"
        '';
      })
      (pkgs.writeShellApplication {
        name = "playerctl-resume";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          file=$HOME/.player

          $SHELL "$file" && rm "$file"
        '';
      })
    ];

    keybind.binds = [
      {
        modifiers = [ "SUPER" ];
        key = "SPACE";
        action = "playerctl -a play-pause";
      }
    ];

    features.desktop = {
      on-lock = [ "playerctl-save && playerctl -a pause" ];
      on-unlock = [ "playerctl-resume" ];
    };
  };
}
