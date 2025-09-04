{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.features.desktop.wlogout = lib.mkEnableOption "wlogout";

  config = lib.mkIf config.features.desktop.wlogout {
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
        @define-color base00 #${config.lib.stylix.colors.base00};
        @define-color base01 #${config.lib.stylix.colors.base01};
        @define-color base02 #${config.lib.stylix.colors.base02};
        @define-color base03 #${config.lib.stylix.colors.base03};
        @define-color base04 #${config.lib.stylix.colors.base04};
        @define-color base05 #${config.lib.stylix.colors.base05};
        @define-color base06 #${config.lib.stylix.colors.base06};
        @define-color base07 #${config.lib.stylix.colors.base07};
        @define-color base08 #${config.lib.stylix.colors.base08};
        @define-color base09 #${config.lib.stylix.colors.base09};
        @define-color base0A #${config.lib.stylix.colors.base0A};
        @define-color base0B #${config.lib.stylix.colors.base0B};
        @define-color base0C #${config.lib.stylix.colors.base0C};
        @define-color base0D #${config.lib.stylix.colors.base0D};
        @define-color base0E #${config.lib.stylix.colors.base0E};
        @define-color base0F #${config.lib.stylix.colors.base0F};

        * {
            background-image: none;
            box-shadow: none;
        }

        window {
            font-family: monospace;
            font-size: 14pt;
            color: @base05;
            background-color: alpha(@base01, 0.5);
        }

        button {
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
            background-color: alpha(@base00, 0.75);
            color: @base05;
            border-color: @base03;
            border-width: 0.2rem;
            border-radius: 2rem;
            margin: 10px;
        }

        button:focus, button:active, button:hover {
            background-color: @base02;
            border-color: @base0D;
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

    keybind.binds = [
      {
        modifiers = [ "SUPER" ];
        key = "ESCAPE";
        action = "wlogout -b 2 -L 480 -R 480";
      }
    ];
  };
}
