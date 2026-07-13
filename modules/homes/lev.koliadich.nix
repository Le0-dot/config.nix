{ den, inputs, ... }:
{
  den.aspects."lev.koliadich" = {
    includes = [
      den.aspects.nix
      den.aspects.terminal
      den.aspects.desktop.hyprland
    ];

    homeManager = { pkgs, config, ... }: {
      imports = [
        inputs.agenix.homeManagerModules.default

        ../_home/wm-common.nix
        ../_home/playerctl.nix
        ../_home/cliphist.nix
        ../_home/tofi.nix
        ../_home/kanshi.nix
        ../_home/wlogout.nix
        ../_home/dunst.nix
        ../_home/ghostty.nix
        ../_home/hyprlock.nix
        ../_home/hypridle.nix
        ../_home/hyprpaper.nix
        ../_home/waybar.nix
      ];

      # Provide perSystem.self.* for _home/ modules that reference custom packages
      _module.args.perSystem = {
        self = {
          choose-repo = import ../_packages/choose-repo.nix { inherit pkgs; };
          clipselect = import ../_packages/clipselect.nix { inherit pkgs; };
          hyprlock = import ../_packages/hyprlock.nix { inherit pkgs; };
          hyprpaper = import ../_packages/hyprpaper.nix { inherit pkgs; };
        };
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
          serif.name = "Fira Sans";
          sansSerif.name = "Fira Sans";
          monospace = {
            package = pkgs.nerd-fonts.fira-code;
            name = "FiraCode Nerd Font Mono";
          };
        };
      };

      programs.zsh = {
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

      programs.git.settings.user = {
        name = "Lev Koliadich";
        email = "lkolyadich@gmail.com";
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
      services.playerctld.enable = true;
      services.cliphist.enable = true;
      services.dunst.enable = true;
      programs.tofi.enable = true;
      programs.ghostty.enable = true;
    };
  };

  den.aspects."lev.koliadich@omega" = {
    includes = [
      den.aspects.terminal.television
      (den.aspects.terminal.neovim "projects/config.nvim")
    ];
  };
}
