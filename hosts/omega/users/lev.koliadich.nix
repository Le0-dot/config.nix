{
  pkgs,
  flake,
  inputs,
  config,
  perSystem,
  ...
}:

{
  imports = [
    inputs.stylix.homeModules.stylix
    inputs.keybind.homeModules.keybind
    inputs.agenix.homeManagerModules.default

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
    flake.homeModules.dunst
    flake.homeModules.ghostty
    flake.homeModules.hyprland
    flake.homeModules.hyprlock
    flake.homeModules.hypridle
    flake.homeModules.hyprpaper
    flake.homeModules.hyprshot
    flake.homeModules.waybar
    flake.homeModules.chrome
  ];

  config = {
    home.stateVersion = "25.05";
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    home.shellAliases = {
      cat = "bat -p";
    };

    home.packages = [
      perSystem.self.choose-repo
      perSystem.self.clipselect
    ];

    keybind.binds = [
      {
        modifiers = [ "SUPER" ];
        key = "P";
        action = "choose-repo ${config.wm.dmenu} ~/projects 3 | xargs -I{} ${config.wm.term} -e direnv exec {} nvim -c 'WithSession {}'";
      }
    ];

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
    programs.starship.enable = true;
    programs.zellij.enable = true;

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
    programs.gh.enable = true;

    stylix.targets.yazi.enable = true;
    programs.yazi = {
      enable = true;
      settings.mgr.show_hidden = true;
    };

    wayland.windowManager.hyprland.enable = true;
    services.hyprpolkitagent.enable = true;
    services.hypridle.enable = true;
    programs.hyprlock.enable = true;
    services.hyprpaper.enable = true;
    programs.hyprshot.enable = true;
    services.kanshi.enable = true;
    programs.waybar.enable = true;
    programs.wlogout.enable = true;
    programs.brightnessctl.enable = true;
    programs.wireplumber.enable = true;
    services.playerctld.enable = true;
    services.cliphist.enable = true;
    services.dunst.enable = true;
    programs.tofi.enable = true;
    programs.ghostty.enable = true;
  };
}
