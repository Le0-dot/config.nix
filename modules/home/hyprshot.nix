{ lib, config, ... }:

{
  config = lib.mkIf config.programs.hyprshot.enable {
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
