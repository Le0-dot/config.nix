{ lib, config, ... }:

{
  options.features.desktop.hyprshot = lib.mkEnableOption "hyprshot";

  config = lib.mkIf config.features.desktop.hyprshot {
    programs.hyprshot.enable = true;

    keybind.binds = [
      {
        modifiers = [ ];
        key = "Print";
        action = "hyprshot -m region";
      }
      {
        modifiers = [ "SUPER" ];
        key = "Print";
        action = "hyprshot -m window";
      }
      {
        modifiers = [
          "SUPER"
          "SHIFT"
        ];
        key = "Print";
        action = "hyprshot -m output";
      }
    ];
  };
}
