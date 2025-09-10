{
  pkgs,
  lib,
  config,
  ...
}:

let
  workspaces = {
    "1" = "1";
    "2" = "2";
    "3" = "3";
    "4" = "4";
    "5" = "5";
  };
  navigation = {
    H = "l";
    J = "d";
    K = "u";
    L = "r";
  };
in
{
  options.features.desktop.hyprland = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.features.desktop.hyprland {
    home.packages = with pkgs; [
      wl-clipboard-rs
      networkmanagerapplet
      (pkgs.writeShellScriptBin "start-desktop" "Hyprland")
    ];

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    stylix.targets.hyprland.enable = true;
    keybind.hyprland.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      systemd.enableXdgAutostart = true;
      systemd.variables = [ "--all" ];
      settings = {
        exec-once = [
          "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
        ];
        "$mod" = "SUPER";
        bind = [
          "$mod CTRL, Q, exit"
          "$mod, W, killactive"
          "$mod, Tab, fullscreen, 1"
          "$mod SHIFT, V, togglefloating"
          "$mod SHIFT, V, centerwindow"
        ]
        ++ lib.mapAttrsToList (key: workspace: "$mod, ${key}, workspace, ${workspace}") workspaces
        ++ lib.mapAttrsToList (key: direction: "$mod, ${key}, movefocus, ${direction}") navigation
        ++ lib.mapAttrsToList (
          key: workspace: "$mod SHIFT, ${key}, movetoworkspacesilent, ${workspace}"
        ) workspaces
        ++ lib.mapAttrsToList (key: direction: "$mod SHIFT, ${key}, movewindow, ${direction}") navigation
        ++ lib.mapAttrsToList (
          key: direction: "$mod CTRL, ${key}, movecurrentworkspacetomonitor, ${direction}"
        ) navigation;

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
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
          "tag +development, title:.*Monkeytype.*"
          "tag +browser, class:google-chrome"
          "tag +social, class:.*Slack.*"
          "tag +video, title:.*Meet.*"
          "tag +media, class:spotify"
          "tag +media, title:.*Audiobookshelf.*"

          "opaque 1, tag:video"
          "nodim 1, tag:video"

          "workspace 1, tag:development"
          "workspace 2, tag:browser"
          "workspace 3, tag:social"
          "workspace 4, tag:video"
          "workspace 5, tag:media"
        ];

        general = {
          border_size = 2;
          gaps_in = 5;
          gaps_out = 5;
        };

        decoration = {
          rounding = 10;
          inactive_opacity = 0.9;
          dim_inactive = true;
        };

        animations.enabled = false;

        cursor.inactive_timeout = 10;

        input = {
          kb_layout = "us, ru";
          kb_options = "grp:alt_shift_toggle";

          numlock_by_default = true;

          scroll_method = "2fg";

          follow_mouse = true;
        };

        misc.disable_hyprland_logo = true;
        misc.disable_splash_rendering = true;
        misc.background_color = lib.mkForce "0x111111"; # Temporary

        dwindle.force_split = 2;
      };
    };
  };
}
