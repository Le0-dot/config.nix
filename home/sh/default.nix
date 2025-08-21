{ lib, ... }:

{
  imports = [ ./zsh.nix ];

  options.default.sh = lib.mkOption {
    type = lib.types.str;
    description = "Default shell command";
  };

  config = {
    programs.eza = {
      enable = true;
      colors = "always";
      icons = "auto";
    };

    programs.gh.enable = true;

    home.sessionPath = [ "$HOME/.local/bin" ];

    home.shellAliases = {
      ls = "eza";
      ll = "ls -laF --time-style=long-iso";
      tree = "eza --tree -a";
      yc = "git log --pretty=format:%s -1 | wl-copy"; # copy last commit message
      pycharm-wayland = "pycharm-professional -Dawt.toolkit.name=WLToolkit";
    };

    stylix.targets.bat.enable = true;
    programs.bat.enable = true;
    home.shellAliases.cat = "bat -p";

    programs.direnv.enable = true;
    programs.fzf.enable = true;
    programs.lazygit.enable = true;
    programs.uv.enable = true;

    programs.atuin = {
      enable = true;
      settings = {
        dialect = "uk";
        filter_mode_shell_up_key_binding = "session";
        enter_accept = true;
        style = "compact";
        show_help = false;
        show_tabs = false;
        keys.scroll_exits = false;
        stats.common_prefix = [ "sudo" ];
        stats.ignored_commands = [
          "cd"
          "ls"
          "vim"
          "nvim"
          "v"
        ];
      };
    };
  };
}
