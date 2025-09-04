{ pkgs, config, ... }:
{
  imports = [ ./essential.nix ];
  config = {
    features = {
      cli = {
        git = true;
        starship = true;
        yazi = true;
        zellij = true;
        zsh = true;
        neovim = {
          enable = true;
          config = "${config.home.homeDirectory}/projects/config.nvim";
        };
      };
      desktop = {
        brightnessctl = true;
        chrome = true;
        dunst = true;
        fuzzel = true;
        ghostty = true;
        hyprland = true;
        hyprlock = true;
        hyprpaper = true;
        hyprshot = true;
        kanshi = true;
        playerctl = true;
        waybar = true;
        wireplumber = true;
        wlogout = true;
      };
    };

    home.packages = [
      (pkgs.writeShellApplication {
        name = "pycharm-professional";
        runtimeInputs = [ pkgs.jetbrains.pycharm-professional ];
        text = ''
          pycharm-professional -Dawt.toolkit.name=WLToolkit
        '';
      })
    ];
  };
}
