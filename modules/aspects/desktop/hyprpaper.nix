{
  den.aspects.desktop.hyprpaper.homeManager = {
    # stylix.targets.hyprpaper.enable = true; # TODO Use stylix to set wallpaper
    services.hyprpaper = {
      enable = true;
      # package = perSystem.self.hyprpaper; # FIXME
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
