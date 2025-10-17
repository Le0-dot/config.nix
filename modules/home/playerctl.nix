{
  lib,
  pkgs,
  config,
  ...
}:

let
  playerctl-save = pkgs.writeShellApplication {
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
  };
  playerctl-resume = pkgs.writeShellApplication {
    name = "playerctl-resume";
    runtimeInputs = [
      pkgs.playerctl
      pkgs.coreutils
    ];
    text = ''
      file=$HOME/.player-resume

      [ -e "$file" ] && $SHELL "$file" && rm "$file"
    '';
  };
in
{
  config = lib.mkIf config.services.playerctld.enable {
    home.packages = [
      playerctl-save
      playerctl-resume
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

    systemd.user.services = {
      playerctl-save = {
        Unit = {
          Description = "Save media player states before locking the session";
          Requires = [
            "graphical-session.target"
            "playerctld.service"
          ];
        };
        Install.WantedBy = [ "on-session-lock.target" ];
        Service = {
          Type = "oneshot";
          ExecStart = [
            "${playerctl-save}/bin/playerctl-save"
            "${pkgs.playerctl}/bin/playerctl -a pause"
          ];
        };
      };
      playerctl-resume = {
        Unit = {
          Description = "Save media player states before locking the session";
          Requires = [
            "graphical-session.target"
            "playerctld.service"
          ];
        };
        Install.WantedBy = [ "on-session-unlock.target" ];
        Service = {
          ExecStart = "${playerctl-resume}/bin/playerctl-resume";
        };
      };
    };
  };
}
