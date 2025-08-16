{ pkgs, lib, config, ... }:

{
  options.bar.waybar = lib.mkEnableOption "waybar";

  config = lib.mkIf config.bar.waybar {
    default.bar = lib.mkDefault "waybar";

    stylix.targets.waybar = {
      enable = true;
      addCss = false;
    };

    home.packages = [ pkgs.pwvucontrol ];

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          reload_style_on_change = true;
          no-center = true;
          output = "eDP-1";
          margin-bottom = 5;
          modules-left = [ "hyprland/workspaces" ];
          modules-right = [
            "tray"
            "wireplumber"
            "backlight"
            "battery"
            "hyprland/language"
            "clock"
          ];

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              # "6" = "6";
              # "7" = "";
              # "8" = "";
              # "9" = "";
              # "10" = "";
            };
            persistent-workspaces = { "*" = 5; };
          };

          tray = { spacing = 10; };

          wireplumber = {
            format = "{volume}% {icon}";
            format-muted = "";
            format-icons = [ "" "" "" ];
            scroll-step = 5;
            on-click = "pwvucontrol";
          };

          backlight = {
            format = "{icon}";
            format-icons = [ "" "" "" "" "" "" "" "" "" "" "" ];
            scroll-step = 5;
            tooltip = false;
          };

          battery = {
            interval = 5;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon}";
            format-icons = {
              default = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
              charging = [ "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" ];
              plugged = "󰂅";
            };
            format-time = "{H}h {m}m";
          };

          "hyprland/language" = {
            format-en = "EN";
            format-ru = "RU";
          };

          clock = {
            format = "{:L%H:%M}";
            tooltip-format = "<tt><big>{calendar}</big></tt>";
            calendar = {
              mode = "month";
              mode-mon-col = 3;
              format = {
                today =
                  "<span color='#dddd00' background='#000000'><b><u>{}</u></b></span>";
              };
            };
            actions = { on-click = "mode"; };
          };
        };
      };
      style = ''
        * {
            font-family: 'FiraCode Nerd Font Propo';
            font-size: 16px;
            min-height: 0;
        }

        #waybar {
            background: transparent;
            color: @base05;
        }

        #workspaces {
            background: @base02;
            border-radius: 1rem;
            margin: 5px;
            margin-left: 0.5rem;
            padding-left: 0.5rem;
            padding-right: 0.5rem;
        }

        #workspaces button {
            color: @base07;
            border-radius: 1rem;
        }

        #workspaces button:not(.empty) {
            color: @base0D;
        }

        #workspaces button.active {
            color: @base0E;
        }

        #workspaces button.urgent {
            color: @base08;
        }

        .modules-right > widget > * {
            background: @base02;
            padding: 0.5rem 0.5rem;
            margin: 5px 0;
        }

        #tray {
            border-radius: 1rem;
            margin-right: 0.5rem;
            padding-left: 1rem;
            padding-right: 1rem;
        }

        #wireplumber {
            color: @base06;
            border-radius: 1rem 0px 0px 1rem;
            padding-left: 1rem;
        }

        #wireplumber.muted {
            color: @base05;
        }

        #backlight {
            color: @base0A;
        }

        #battery {
            color: @base0D;
            border-radius: 0px 1rem 1rem 0px;
            margin-right: 0.5rem;
            padding-right: 1rem;
        }

        #battery.charging {
            color: @base0B;
        }

        #battery.warning:not(.charging) {
            color: @base09;
        }

        @keyframes blink {
            to {
                color: @base08;
            }
        }

        #battery.critical:not(.charging) {
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #language {
            color: @base0C;
            border-radius: 1rem 0px 0px 1rem;
            padding-left: 1rem;
        }

        #clock {
            color: @base0D;
            border-radius: 0px 1rem 1rem 0px;
            margin-right: 0.5rem;
            padding-right: 1rem;
        }
      '';
    };
  };
}
