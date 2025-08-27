{ lib, config, ... }:

let
  bind = keys: actions: { "bind \"${keys}\"" = actions; };
  groupBinds = binds: builtins.foldl' (x: y: x // y) { } binds;
in
{
  options.features.cli.zellij = lib.mkEnableOption "zellij";

  config = lib.mkIf config.features.cli.zellij {
    home.shellAliases = {
      zellij = "zellij -l welcome";
    };

    stylix.targets.zellij.enable = true;

    programs.zellij = {
      enable = true;
      settings = {
        default_mode = "locked";
        simplified_ui = true;
        pane_frames = false;
        show_startup_tips = false;
        session_serialization = true;
        pane_viewport_serialization = true;
        serialization_interval = 60;
        keybinds = {
          shared = groupBinds [
            (bind "Alt d" { Detach = { }; })
            (bind "Alt w" {
              LaunchOrFocusPlugin = {
                _args = [ "session-manager" ];
                floating = true;
                move_to_focused_tab = true;
              };
              SwitchToMode = "Locked";
            })

            (bind "Alt t" {
              NewTab = {
                layout = "new-tab";
              };
              SwitchToMode = "Locked";
            })
            (bind "Alt 1" {
              GoToTab = 1;
              SwitchToMode = "Locked";
            })
            (bind "Alt 2" {
              GoToTab = 2;
              SwitchToMode = "Locked";
            })
            (bind "Alt 3" {
              GoToTab = 3;
              SwitchToMode = "Locked";
            })
            (bind "Alt 4" {
              GoToTab = 4;
              SwitchToMode = "Locked";
            })
            (bind "Alt 5" {
              GoToTab = 5;
              SwitchToMode = "Locked";
            })
            (bind "Alt 6" {
              GoToTab = 6;
              SwitchToMode = "Locked";
            })
            (bind "Alt 7" {
              GoToTab = 7;
              SwitchToMode = "Locked";
            })
            (bind "Alt 8" {
              GoToTab = 8;
              SwitchToMode = "Locked";
            })
            (bind "Alt 9" {
              GoToTab = 9;
              SwitchToMode = "Locked";
            })

            (bind "Alt p" { NewPane = { }; })
            (bind "Alt h" { MoveFocusOrTab = "Left"; })
            (bind "Alt j" { MoveFocusOrTab = "Down"; })
            (bind "Alt k" { MoveFocusOrTab = "Up"; })
            (bind "Alt l" { MoveFocusOrTab = "Right"; })

            (bind "Alt g" {
              NewTab = {
                layout = "lazygit";
              };
            })
          ];
          "shared_except \"Locked\"" = groupBinds [
            (bind "Ctrl g" { SwitchToMode = "Locked"; })
            (bind "Esc" { SwitchToMode = "Locked"; })
          ];
        };
      };
    };

    home.file.".config/zellij/layouts/development.kdl".text = ''
      layout {
        default_tab_template {
          pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
          }
          children
        }
        tab name="nvim" focus=true {
          pane {
            command "direnv"
            args "exec" "." "nvim" "-c" "WithSession"
          }
        }
        tab name="zsh"
      }
    '';

    home.file.".config/zellij/layouts/new-tab.kdl".text = ''
      layout {
        tab focus=true {
          pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
          }
          pane
        }
      }
    '';

    home.file.".config/zellij/layouts/lazygit.kdl".text = ''
      layout {
        tab name="lazygit" focus=true {
          pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
          }
          pane command="lazygit" close_on_exit=true
        }
      }
    '';
  };
}
