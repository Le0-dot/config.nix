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
      package = pkgs.stable.hyprpaper;
      enable = true;
      settings = {
        ipc = true;
      };
    };
  };
}
