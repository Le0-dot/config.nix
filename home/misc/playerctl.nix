{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "playerctl-save" ''
      #!/usr/bin/env sh

      file=~/.player

      function status() {
          playerctl -a metadata -f '{{ playerName }} {{ status }}'
      }

      function status-to-script() {
          sed '/Paused/d; /Stopped/d; s/^\(.\+\) Playing/playerctl -p \1 play/'
      }

      status | status-to-script > $file
    '')
    (pkgs.writeShellScriptBin "playerctl-resume" ''
      #!/usr/bin/env sh

      file=~/.player

      sh $file && rm $file
    '')
  ];

  keybind.binds = [
    {
      modifiers = [
        "SUPER"
        "ALT"
      ];
      key = "SPACE";
      action = "playerctl -a play-pause";
    }
  ];
}
