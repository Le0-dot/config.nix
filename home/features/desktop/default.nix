{ lib, ... }:

{
  imports = [
    ./ghostty.nix
    ./chrome.nix
    ./fuzzel.nix
    ./tofi.nix
    ./brightnessctl.nix
    ./wireplumber.nix
    ./playerctl.nix
    ./cliphist.nix

    ./dunst.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprshot.nix
    ./kanshi.nix
    ./waybar.nix
    ./wlogout.nix
    ./project-switch.nix
  ];

  options.features.desktop = {
    dmenu = lib.mkOption {
      type = lib.types.str;
      description = "Application to run as default dmenu compatible picker";
    };
    term = lib.mkOption {
      type = lib.types.str;
      description = "Application to run as default terminal emulator";
    };
    on-lock = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of scripts to run on session lock";
    };
    on-unlock = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of scripts to run on session unlock";
    };
  };
}
