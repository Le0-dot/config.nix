{
  lib,
  pkgs,
  config,
  perSystem,
  ...
}:

{
  config = lib.mkIf config.services.cliphist.enable {
    home.packages = [ perSystem.self.clipselect ];

    keybind.binds = [
      {
        modifiers = [
          "SUPER"
          "CTRL"
        ];
        key = "V";
        action = "clipselect ${config.wm.dmenu}";
      }
    ];
  };
}
