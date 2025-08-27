{
  lib,
  pkgs,
  config,
  ...
}:

{
  features = {
    cli = {
      git = lib.mkDefault true;
      starship = lib.mkDefault true;
      yazi = lib.mkDefault true;
      zellij = lib.mkDefault true;
      zsh = lib.mkDefault true;
      neovim = {
        enable = lib.mkDefault true;
        config = lib.mkDefault "${config.home.homeDirectory}/projects/config.nvim";
      };
    };
    desktop = {
      brightnessctl = lib.mkDefault true;
      chrome = lib.mkDefault true;
      dunst = lib.mkDefault true;
      fuzzel = lib.mkDefault true;
      ghostty = lib.mkDefault true;
      hyprland = lib.mkDefault true;
      hyprlock = lib.mkDefault true;
      hyprpaper = lib.mkDefault true;
      kanshi = lib.mkDefault true;
      playerctl = lib.mkDefault true;
      waybar = lib.mkDefault true;
      wireplumber = lib.mkDefault true;
      wlogout = lib.mkDefault true;
    };
  };

  home.username = "lev.koliadich";
  home.homeDirectory = "/home/${config.home.username}";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
  home.packages = [
    pkgs.nil
  ];

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  # TODO: Extract stylix config into another file
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
}
