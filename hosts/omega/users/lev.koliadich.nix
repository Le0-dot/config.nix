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
  ];

  config = {
    home.stateVersion = "25.05";
    home.username = "lev.koliadich";
    home.homeDirectory = "/home/${config.home.username}";
    home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

    programs.zsh.enable = true;
    programs.starship.enable = true;

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
