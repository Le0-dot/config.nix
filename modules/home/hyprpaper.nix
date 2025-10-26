{
  pkgs,
  lib,
  config,
  perSystem,
  ...
}:

{
  config = lib.mkIf config.services.hyprpaper.enable {
    services.hyprpaper = {
      package = perSystem.self.hyprpaper;
      settings = {
        ipc = true;
        preload = [ "~/Pictures/Wallpaper.jpeg" ];
        wallpaper = [ ",~/Pictures/Wallpaper.jpeg" ];
      };
    };
  };
}
