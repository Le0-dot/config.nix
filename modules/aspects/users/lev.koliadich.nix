{ den, ... }:
{
  den.aspects."lev.koliadich" = {
    includes = [
      den.aspects.nix
      den.aspects.terminal
    ];

    homeManager = {
      programs.git.settings.user = {
        name = "Lev Koliadich";
        email = "lkolyadich@gmail.com";
      };
    };
  };

  den.aspects."lev.koliadich@omega" = {
    includes = [
      den.aspects.desktop
      den.aspects.desktop.ghostty
      den.aspects.terminal.television
      (den.aspects.terminal.neovim "projects/config.nvim")
    ];
    homeManager = {
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
    };
  };
}
