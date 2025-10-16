{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf config.services.hyprpaper.enable {
    services.hyprpaper = {
      package = pkgs.writeShellScriptBin "hyprpaper" ''
        export LD_PRELOAD="${pkgs.sssd}/lib/libnss_sss.so.2:$LD_PRELOAD"
        exec ${pkgs.hyprpaper}/bin/hyprpaper "$@"
      '';
      settings = {
        ipc = true;
        preload = [ "~/Pictures/Wallpaper.jpeg" ];
        wallpaper = [ ",~/Pictures/Wallpaper.jpeg" ];
      };
    };
  };
}
