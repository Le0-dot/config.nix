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
  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    home.packages = [
      pkgs.wl-clipboard-rs
      pkgs.networkmanagerapplet
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
      systemd.enable = true;
      systemd.enableXdgAutostart = true;
      systemd.variables = [ "--all" ];
      settings = {
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
          "match:workspace w[tv1], match:float false, border_size 0"
          "match:workspace w[tv1], match:float false, rounding 0"
          "match:workspace f[1], match:float false, border_size 0"
          "match:workspace f[1], match:float false, rounding 0"

          "match:class .*ghostty.*, tag +development"
          "match:title .*Monkeytype.*, tag +development"
          "match:class google-chrome, tag +browser"
          "match:class .*Slack.*, tag +social"
          "match:title .*Meet.*, tag +video"
          "match:class spotify, tag +media"
          "match:title .*Audiobookshelf.*, tag +media"

          "match:tag video, opaque on"
          "match:tag video, no_dim on"
          "match:tag video, fullscreen on"

          "match:tag development, workspace 1"
          "match:tag browser, workspace 2"
          "match:tag social, workspace 3"
          "match:tag video, workspace 4"
          "match:tag media, workspace 5"
        ];

        general = {
          border_size = 2;
          gaps_in = 5;
          gaps_out = 5;
        };

        decoration = {
          rounding = 10;
          inactive_opacity = 0.75;
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

        dwindle.force_split = 2;
      };
    };
  };
}
