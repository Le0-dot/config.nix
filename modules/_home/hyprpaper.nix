{
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
        splash = false;
        wallpaper = {
          monitor = "";
          path = "~/Pictures/Wallpaper.jpeg";
        };
      };
    };
  };
}
