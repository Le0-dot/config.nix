# User aspect for lev.koliadich (standalone HM on omega).
{ den, inputs, ... }:
{
  den.homes.x86_64-linux."lev.koliadich@omega" = { };

  den.aspects."lev.koliadich" = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
    ];

    homeManager = { pkgs, config, ... }: {
      imports = [
        inputs.stylix.homeModules.stylix
        inputs.agenix.homeManagerModules.default

        ../_home/git.nix
        ../_home/zsh.nix
        ../_home/starship.nix
        ../_home/atuin.nix
        ../_home/neovim.nix
        ../_home/television.nix
        ../_home/wm-common.nix
        ../_home/playerctl.nix
        ../_home/cliphist.nix
        ../_home/tofi.nix
        ../_home/kanshi.nix
        ../_home/wlogout.nix
        ../_home/dunst.nix
        ../_home/ghostty.nix
        ../_home/hyprland.nix
        ../_home/hyprlock.nix
        ../_home/hypridle.nix
        ../_home/hyprpaper.nix
        ../_home/waybar.nix
      ];

      # Provide perSystem.self.* for _home/ modules that reference custom packages
      _module.args.perSystem = {
        self = {
          choose-repo = import ../../packages/choose-repo.nix { inherit pkgs; };
          clipselect = import ../../packages/clipselect.nix { inherit pkgs; };
          hyprlock = import ../../packages/hyprlock.nix { inherit pkgs; };
          hyprpaper = import ../../packages/hyprpaper.nix { inherit pkgs; };
        };
      };

      nix.gc.automatic = true;
      nixpkgs.config.allowUnfree = true;

      home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
      home.shellAliases.cat = "bat -p";

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
  };
}
