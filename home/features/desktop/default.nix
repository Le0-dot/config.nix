{ lib, ... }:

{
  imports = [
    ./ghostty.nix
    ./chrome.nix
    ./fuzzel.nix
    ./brightnessctl.nix
    ./wireplumber.nix
    ./playerctl.nix

    ./dunst.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprshot.nix
    ./kanshi.nix
    ./waybar.nix
    ./wlogout.nix
  ];

  options.features.desktop = {
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
