{ pkgs, lib, config, ... }:

let
  workspaces = {
    "1" = "1";
    "2" = "2";
    "3" = "3";
    "4" = "4";
    "5" = "5";
    "6" = "6";
    "7" = "7";
    "8" = "8";
    "9" = "9";
    "0" = "10";
  };
  navigation = {
    H = "l";
    J = "d";
    K = "u";
    L = "r";
  };
in {
  options.wm.hyprland = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.wm.hyprland {
    default.wm = lib.mkDefault "Hyprland";

    home.packages = with pkgs; [
      wl-clipboard-rs
      wireplumber
      wlrctl
      brightnessctl
      playerctl
      networkmanagerapplet
    ];

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    stylix.targets.hyprland.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      systemd.enableXdgAutostart = true;
      systemd.variables = ["--all"];
      settings = {
        exec-once = [ "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1" "kanshi" config.default.bar "wl-paste --watch cliphist store" ];
        "$mod" = "SUPER";
        bind = [
          "$mod CTRL, Q, exit"
          "$mod, W, killactive"
          "$mod, Tab, fullscreen, 1"
          "$mod SHIFT, V, togglefloating"
          "$mod SHIFT, V, centerwindow"

          "$mod, Return, exec, ${config.default.terminal}"
          "$mod Shift, Return, exec, ${config.default.runner}"
          "$mod, Escape, exec, ${config.default.powermenu}"
          "$mod, F, exec, wlrctl window focus google-chrome || hyprctl dispatch exec google-chrome"
        ] ++ lib.mapAttrsToList
          (key: workspace: "$mod, ${key}, workspace, ${workspace}") workspaces
          ++ lib.mapAttrsToList
          (key: direction: "$mod, ${key}, movefocus, ${direction}") navigation
          ++ lib.mapAttrsToList
          (key: workspace: "$mod SHIFT, ${key}, movetoworkspacesilent, ${workspace}") workspaces
          ++ lib.mapAttrsToList
          (key: direction: "$mod SHIFT, ${key}, movewindow, ${direction}") navigation
          ++ lib.mapAttrsToList
          (key: direction: "$mod CTRL, ${key}, movecurrentworkspacetomonitor, ${direction}") navigation;

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"

          "$mod ALT, Space, exec, playerctl -a play-pause"
        ];

        binde = [
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ];

        workspace = [
          "w[tv1], gapsout:0, gapsin:0"
          "f[1], gapsout:0, gapsin:0"
        ];

        windowrule = [
          "bordersize 0, floating:0, onworkspace:w[tv1]"
          "rounding 0, floating:0, onworkspace:w[tv1]"
          "bordersize 0, floating:0, onworkspace:f[1]"
          "rounding 0, floating:0, onworkspace:f[1]"

          "tag +development, class:.*ghostty.*"
          "tag +browser, class:google-chrome"
          "tag +social, class:.*Slack.*"
          "tag +video, title:.*Meet.*"
          "tag +media, class:spotify"

          "opaque 1, tag:video"
          "nodim 1, tag:video"

          "workspace 1, tag:development"
          "workspace 2, tag:browser"
          "workspace 3, tag:social"
          "workspace 4, tag:video"
          "workspace 5, tag:media"
        ];

        debug.disable_logs = false;

        general = {
          border_size = 2;
          no_border_on_floating = false;
          gaps_in = 5;
          gaps_out = 5;
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          active_opacity = 1.0;
          inactive_opacity = 0.9;
          dim_inactive = true;
          dim_stength = 0.2;
          shadow = {
            range = 4;
            render_power = 3;
          };
        };

        animations.enabled = false;

        cursor.inactive_timeout = 10;

        input = {
          kb_layout = "us, ru";
          kb_options = "grp:alt_shift_toggle";

          numlock_by_default = true;

          scroll_method = "2fg";

          follow_mouse = true;

          touchpad.natural_scroll = false;

          sensitivity = 0;
        };

        gestures.workspace_swipe = false;

        misc.disable_hyprland_logo = true;
        misc.disable_splash_rendering = true;
        misc.allow_session_lock_restore = true;
        misc.background_color = lib.mkForce "0x111111"; # Temporary

        dwindle = {
          pseudotile = false;
          force_split = 2;
          preserve_split = true;
        };
      };
    };

    # services.hyprpolkitagent.enable = true;
    # services.polkit-gnome.enable = true;

    services.kanshi = {
      enable = true;
      settings = [
        {
          output.criteria = "eDP-1";
          output.mode = "1920x1200@60";
          output.scale = 1.0;
          output.alias = "BUILTIN";
        }
        {
          output.criteria = "Dell Inc. DELL P2317H V2G517BE336L";
          output.mode = "1920x1080@60";
          output.scale = 1.0;
          output.alias = "LEFT";
        }
        {
          output.criteria = "Dell Inc. DELL P2317H V2G517BE331L";
          output.mode = "1920x1080@60";
          output.scale = 1.0;
          output.alias = "RIGHT";
        }
        {
          profile.name = "default";
          profile.outputs = [{ criteria = "$BUILTIN"; }];
        }
        {
          profile.name = "docked";
          profile.outputs = [
            {
              criteria = "$BUILTIN";
              position = "960,1080";
            }
            {
              criteria = "$LEFT";
              position = "0,0";
            }
            {
              criteria = "$RIGHT";
              position = "1920,0";
            }
          ];
        }
      ];
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof ${config.default.lock} || ${config.default.lock}";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 600;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          # {
          #   timeout = 1800;
          #   on-timeout = "systemctl suspend";
          # }
        ];
      };
    };
  };
}
