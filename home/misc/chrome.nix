{ pkgs, ... }:

{
  home.packages = [
    pkgs.google-chrome
    pkgs.wlrctl
  ];

  keybinds = [
    {
      modifiers = [ "SUPER" ];
      key = "F";
      action = "google-chrome-stable";
    }
  ];
}
