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
    inputs.agenix.homeManagerModules.default

    flake.homeModules.git
    flake.homeModules.zsh
    flake.homeModules.starship
    flake.homeModules.atuin
    flake.homeModules.neovim
    flake.homeModules.television
    flake.homeModules.wm-common
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
    flake.homeModules.waybar
  ];

  config = {
    nix.gc.automatic = true;

    home.stateVersion = "26.05";
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    home.shellAliases = {
      cat = "bat -p";
    };

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

    programs.zsh = {
      enable = true;
      envExtra = ''
        if [ -e /etc/profile.d/system-manager-path.sh ]; then
          . /etc/profile.d/system-manager-path.sh
        else
          echo "Warning: /etc/profile.d/system-manager-path.sh not found. Please ensure that the system manager is installed and configured correctly."
        fi
      '';
      loginExtra = ''
        if uwsm check may-start && uwsm select; then 
          exec uwsm start default
        fi
      '';
    };
    programs.starship.enable = true;
    programs.fzf.enable = true;
    programs.atuin.enable = true;
    programs.direnv.enable = true;
    programs.lazygit.enable = true;
    programs.fd.enable = true;
    programs.television.enable = true;
    programs.ripgrep.enable = true;

    programs.uv.enable = true;
    programs.ty.enable = true;
    programs.npm.enable = true;
    programs.opencode.enable = true;
    programs.claude-code.enable = true;

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
      settings.user = {
        name = "Lev Koliadich";
        email = "lkolyadich@gmail.com";
      };
    };
    programs.gh.enable = true;

    wayland.windowManager.hyprland.enable = true;
    services.hyprpolkitagent.enable = true;
    services.hypridle.enable = true;
    programs.hyprlock.enable = true;
    services.hyprpaper.enable = true;
    programs.hyprshot.enable = true;
    services.kanshi.enable = true;
    programs.waybar.enable = true;
    programs.wlogout.enable = true;
    services.playerctld.enable = true;
    services.cliphist.enable = true;
    services.dunst.enable = true;
    programs.tofi.enable = true;
    programs.ghostty.enable = true;
  };
}
