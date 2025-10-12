{
  flake,
  inputs,
  config,
  ...
}:

{
  imports = [
    inputs.stylix.homeModules.default
    flake.homeModules.git
    flake.homeModules.zsh
    flake.homeModules.starship
    flake.homeModules.atuin
    flake.homeModules.neovim
  ];

  config = {
    home.stateVersion = "25.05";
    home.username = "lev.koliadich";
    home.homeDirectory = "/home/${config.home.username}";
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    home.shellAliases = {
      cat = "bat -p";
    };

    programs.zsh.enable = true;
    programs.starship.enable = true;
    programs.direnv.enable = true;
    programs.lazygit.enable = true;
    programs.fzf.enable = true;
    programs.uv.enable = true;

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

    stylix.targets.yazi.enable = true;
    programs.yazi = {
      enable = true;
      settings.mgr.show_hidden = true;
    };
  };
}
