{ flake, ... }:

{
  imports = [ flake.homeModules.git ];

  config = {
    home.username = "lev.koliadich";
    home.homeDirectory = "/home/lev.koliadich";
    home.stateVersion = "25.05";

    programs.git = {
      enable = true;
      userName = "Lev Koliadich";
      userEmail = "lkolyadich@gmail.com";
    };
  };
}
