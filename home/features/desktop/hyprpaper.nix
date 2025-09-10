{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.features.desktop.hyprpaper = lib.mkEnableOption "hyprpaper";

  config = lib.mkIf config.features.desktop.hyprpaper {
    services.hyprpaper = {
      package = pkgs.writeShellScriptBin "hyprpaper" ''
        export LD_PRELOAD="${pkgs.sssd}/lib/libnss_sss.so.2:$LD_PRELOAD"
        exec ${pkgs.hyprpaper}/bin/hyprpaper "$@"
      '';
      enable = true;
      settings = {
        ipc = true;
        preload = [ "~/Pictures/Wallpaper.jpeg" ];
        wallpaper = [ ",~/Pictures/Wallpaper.jpeg" ];
      };
    };
  };
}
