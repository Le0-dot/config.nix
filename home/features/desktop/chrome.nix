{ lib, config, ... }:
{
  options.features.desktop.chrome = lib.mkEnableOption "chrome";
  config.keybind.binds = lib.mkIf config.features.desktop.chrome [
    {
      modifiers = [
        "SUPER"
      ];
      key = "f";
      action = "google-chrome";
    }
  ];
}
