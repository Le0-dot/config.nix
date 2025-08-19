{ pkgs, config, ... }:

{
  terminal.ghostty = true;
  runner.fuzzel = true;
  lock.hyprlock = true;
  bar.waybar = true;
  wm.hyprland = true;
  dm.kanshi = true;
  powermenu.wlogout = true;
  sh.zsh = true; # Finish configuration
  promt.starship = true;
  multiplexer.zellij = true;
  filemanager.yazi = true;
  notification.dunst = true;
  wallpaper.hyprpaper = true;
  editor.neovim = {
    enable = true;
    config = "/home/lev.koliadich/projects/config.nvim";
  };
  # TODO: Extract stylix config into another file

  home.username = "lev.koliadich";
  home.homeDirectory = "/home/lev.koliadich";

  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;
  home.packages = [ pkgs.jetbrains.pycharm-professional ];

  fonts.fontconfig.enable = true;
  stylix = {
    enable = true;
    autoEnable = false;
    targets = {
      gtk.enable = true;
      font-packages.enable = true;
      fontconfig.enable = true;
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    fonts = {
      serif = {
        package = pkgs.fira-sans;
        name = "Fira Sans";
      };
      sansSerif = {
        package = pkgs.fira-sans;
        name = "Fira Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
    };

  };

  services.playerctld.enable = true;

  programs.home-manager.enable = true;
}
