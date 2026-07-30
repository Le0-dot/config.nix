{ den, ... }:
{
  den.aspects.desktop = {
    includes = [
      den.aspects.desktop.uwsm
      den.aspects.desktop.kanshi # TODO convert kashi config to pure hyprland lua config
      den.aspects.desktop.tofi
      den.aspects.desktop.waybar
      den.aspects.desktop.wlogout
    ];

    homeManager =
      { lib, pkgs, ... }:
      let
        playerctl-freeze = pkgs.writeShellApplication {
          name = "playerctl-freeze";
          runtimeInputs = [
            pkgs.playerctl
            pkgs.jq
          ];
          text = ''
            state_file="''${XDG_STATE_HOME:-$HOME/.local/state}/active-players"
            playerctl metadata --all-players --format '{"player":"{{ playerName }}", "status": "{{ status }}"}' \
              | jq --raw-output 'select(.status == "Playing") | .player' \
              > "$state_file"
            playerctl pause --all-players
          '';
        };
        playerctl-unfreeze = pkgs.writeShellApplication {
          name = "playerctl-unfreeze";
          runtimeInputs = [
            pkgs.findutils
            pkgs.playerctl
          ];
          text = ''
            state_file="''${XDG_STATE_HOME:-$HOME/.local/state}/active-players"
            xargs --arg-file "$state_file" playerctl play --player
          '';
        };
      in
      {
        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 24;
        };

        services.hyprpolkitagent.enable = true;
        services.pipewire = {
          enable = true;
          wireplumber.enable = true;
        };
        services.playerctld.enable = true;

        programs.hyprshot.enable = true;
        home.packages = [
          pkgs.brightnessctl
          pkgs.pwvucontrol
          pkgs.networkmanagerapplet
        ];

        stylix.targets.hyprland.enable = true;
        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;
          extraLuaFiles.config.content = ./hyprland.lua;
        };

        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              on_lock_cmd = lib.getExe playerctl-freeze;
              on_unlock_cmd = lib.getExe playerctl-unfreeze;
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = ''\"enable''\" })'";
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
            ];
          };
        };

        stylix.targets.hyprlock.enable = true;
        programs.hyprlock = {
          enable = true;
          package = pkgs.writeShellApplication {
            name = "hyprlock";
            runtimeInputs = [ pkgs.hyprlock ];
            runtimeEnv = {
              LD_PRELOAD = "${pkgs.sssd}/lib/libnss_sss.so.2";
            };
            text = ''exec hyprlock "$@"'';
          };
          settings = {
            general.hide_cursor = true;
            auth.fingerprint.enabled = true;
            background = lib.mkForce [
              {
                monitor = "";
                path = "screenshot";
                blur_passes = 3;
                blur_size = 3;
              }
            ];
            input-field = {
              monitor = "";
              size = "300, 60";
              halign = "center";
              valign = "center";
              outline_thickness = 4;
              dots_size = 0.33;
              dots_spacing = 0.2;
              dots_center = true;
              fade_on_empty = false;
              placeholder_text = "";
              hide_input = false;
              fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            };
          };
        };

        # stylix.targets.hyprpaper.enable = true; # TODO Use stylix to set wallpaper
        services.hyprpaper = {
          enable = true;
          package = pkgs.writeShellApplication {
            name = "hyprpaper";
            runtimeInputs = [ pkgs.hyprpaper ];
            runtimeEnv = {
              LD_PRELOAD = "${pkgs.sssd}/lib/libnss_sss.so.2";
            };
            text = ''exec hyprpaper "$@"'';
          };
          settings = {
            ipc = true;
            splash = false;
            wallpaper = {
              monitor = "";
              path = "~/Pictures/Wallpaper.jpeg";
            };
          };
        };

        stylix.targets.dunst.enable = true;
        services.dunst = {
          enable = true;
          settings.global = {
            width = 300;
            height = 300;
            offset = "20x50";
            gap_size = 3;
            corner_radius = 10;
            follow = "keyboard";
            markup = "full";
            enable_recursive_icon_lookup = true;
          };
        };
      };

    systemManager = { pkgs, ... }: {
      environment.etc."pam.d/hyprlock".text = ''
        auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so max_tries=3
        auth sufficient ${pkgs.sssd}/lib/security/pam_sss.so try_first_pass
        auth required ${pkgs.linux-pam}/lib/security/pam_deny.so
      '';
    };
  };
}
