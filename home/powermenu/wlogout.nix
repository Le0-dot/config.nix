{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.powermenu.wlogout = lib.mkEnableOption "wlogout";

  config = lib.mkIf config.powermenu.wlogout {
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "loginctl lock-session";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
      style = ''
        * {
            background-image: none;
            box-shadow: none;
        }

        window {
            font-family: monospace;
            font-size: 14pt;
            color: #cad3f5; /* @base05 */
            background-color: rgba(54, 58, 79, 0.5); /* @base02 + 0.5 alpha */
        }

        button {
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
            background-color: rgba(54, 58, 79, 0.5); /* @base02 + 0.5 alpha */
            color: #cad3f5; /* @base05 */
            border-color: #8aadf4; /* @base0D */
            border-width: 0.2rem;
            border-radius: 2rem;
            margin: 10px;
        }

        button:focus, button:active, button:hover {
            background-color: #5b6078; /* @base04 */
            outline-style: none;
        }

        #lock {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"));
        }

        #logout {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"));
        }

        #shutdown {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"));
        }

        #reboot {
            background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"));
        }
      '';
    };

    keybinds = [
      {
        modifiers = [ "SUPER" ];
        key = "ESCAPE";
        action = "wlogout -b 2 -L 480 -R 480";
      }
    ];
  };
}
