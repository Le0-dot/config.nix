{ flake, inputs, ... }:

{
  imports = [
    inputs.stylix.homeModules.default
    flake.homeModules.git
    flake.homeModules.zsh
  ];

  config = {
    home.username = "lev.koliadich";
    home.homeDirectory = "/home/lev.koliadich";
    home.stateVersion = "25.05";

    programs.zsh.enable = true;

    programs.git = {
      enable = true;
      userName = "Lev Koliadich";
      userEmail = "lkolyadich@gmail.com";
    };
  };
}
