{
  den.aspects.desktop.hyprpaper.homeManager = { pkgs, ... }: {
    # stylix.targets.hyprpaper.enable = true; # TODO Use stylix to set wallpaper
    services.hyprpaper = {
      enable = true;
      package = pkgs.writeShellApplication {
        name = "hyprpaper";
        runtimeInputs = [ pkgs.hyprpaper ];
        text = ''exec env LD_PRELOAD=${pkgs.sssd}/lib/libnss_sss.so.2 hyprpaper "$@"'';
      };
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
