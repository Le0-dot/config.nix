{ flake, inputs, ... }:

{
  imports = [
    inputs.stylix.homeModules.default
    flake.homeModules.git
    flake.homeModules.zsh
    flake.homeModules.starship
  ];

  config = {
    home.username = "lev.koliadich";
    home.homeDirectory = "/home/lev.koliadich";
    home.stateVersion = "25.05";

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
