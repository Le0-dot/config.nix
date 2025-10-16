{
  lib,
  pkgs,
  config,
  ...
}:

{
  config = lib.mkIf config.services.playerctld.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "playerctl-save";
        runtimeInputs = [
          pkgs.playerctl
          pkgs.gnused
        ];
        text = ''
          file=$HOME/.player-resume

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
        runtimeInputs = [
          pkgs.playerctl
          pkgs.coreutils
        ];
        text = ''
          file=$HOME/.player-resume

          [ -e "$file" ] && $SHELL "$file" && rm "$file"
        '';
      })
    ];

    keybind.binds = [
      {
        modifiers = [
          "SUPER"
          "CTRL"
        ];
        key = "SPACE";
        action = "playerctl -a play-pause";
      }
    ];

    wm = {
      on-lock = [ "playerctl-save && playerctl -a pause" ];
      on-unlock = [ "playerctl-resume" ];
    };
  };
}
