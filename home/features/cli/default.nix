{ pkgs, config, ... }:

{
  imports = [
    ./git.nix
    ./neovim.nix
    ./zellij.nix
    ./zsh.nix
    ./starship.nix
    ./yazi.nix
  ];

  config = {
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

    home.packages = [
      pkgs.nil
    ];
    programs.uv.enable = true;

    programs.fzf.enable = true;
    programs.lazygit.enable = true;
    programs.direnv.enable = true;

    programs.bat.enable = true;
    stylix.targets.bat.enable = true;

    programs.eza = {
      enable = true;
      colors = "always";
      icons = "auto";
    };

    programs.atuin = {
      enable = true;
      settings = {
        dialect = "uk";
        filter_mode = "directory";
        enter_accept = true;
        style = "compact";
        show_help = false;
        show_tabs = false;
        keys.scroll_exits = false;
      };
    };

    home.shellAliases = {
      cat = "bat -p";
      yc = "git log --pretty=format:%s -1 | wl-copy";
      pycharm-wayland = "pycharm-professional -Dawt.toolkit.name=WLToolkit";
    };
  };
}
