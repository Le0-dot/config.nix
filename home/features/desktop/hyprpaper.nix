# TODO: Try with stable
{ lib, config, ... }:

{
  options.wallpaper.hyprpaper = lib.mkEnableOption "hyprpaper";

  config = lib.mkIf config.wallpaper.hyprpaper {
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = true;
      };
    };
  };
}
