{
  pkgs,
  flake,
  inputs,
  config,
  ...
}:

{
  imports = [
    inputs.stylix.homeModules.stylix
    inputs.keybind.homeModules.keybind

    flake.homeModules.git
    flake.homeModules.zsh
    flake.homeModules.starship
    flake.homeModules.atuin
    flake.homeModules.neovim
    flake.homeModules.zellij

    flake.homeModules.wm-common

    flake.homeModules.brightnessctl
    flake.homeModules.wireplumber
    flake.homeModules.playerctl
    flake.homeModules.cliphist
    flake.homeModules.tofi
    flake.homeModules.kanshi
    flake.homeModules.wlogout
  ];

  config = {
    home.stateVersion = "25.05";
    home.username = "lev.koliadich";
    home.homeDirectory = "/home/${config.home.username}";
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    home.shellAliases = {
      cat = "bat -p";
    };

    stylix = {
      enable = true;
      autoEnable = false; # Causes issues on ubuntu 24.04
      targets = {
        gtk.enable = true;
        font-packages.enable = true;
        fontconfig.enable = true;
      };
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
      fonts = {
        serif = {
          # package = pkgs.fira;
          name = "Fira Sans";
        };
        sansSerif = {
          # package = pkgs.fira;
          name = "Fira Sans";
        };
        monospace = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font Mono";
        };
      };
    };

    programs.zsh.enable = true;
    programs.atuin.enable = true;
    programs.direnv.enable = true;
    programs.lazygit.enable = true;
    programs.fzf.enable = true;
    programs.uv.enable = true;

    stylix.targets.starship.enable = true;
    programs.starship.enable = true;

    stylix.targets.bat.enable = true;
    programs.bat.enable = true;

    programs.eza = {
      enable = true;
      colors = "always";
      icons = "auto";
    };

    programs.neovim = {
      enable = true;
      config = "${config.home.homeDirectory}/projects/config.nvim";
    };

    programs.git = {
      enable = true;
      userName = "Lev Koliadich";
      userEmail = "lkolyadich@gmail.com";
    };

    stylix.targets.zellij.enable = true;
    programs.zellij.enable = true;

    stylix.targets.yazi.enable = true;
    programs.yazi = {
      enable = true;
      settings.mgr.show_hidden = true;
    };

    programs.tofi.enable = true;

    programs.brightnessctl.enable = true;
    programs.wireplumber.enable = true;
    services.playerctld.enable = true;
    services.cliphist.enable = true;
    services.kanshi.enable = true;
    programs.wlogout.enable = true;
  };
}
