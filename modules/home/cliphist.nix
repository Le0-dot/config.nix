{
  lib,
  pkgs,
  config,
  ...
}:

{
  config = lib.mkIf config.services.cliphist.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "clipselect";
        runtimeInputs = [
          pkgs.wl-clipboard-rs
          pkgs.cliphist
        ];
        text = ''
          cliphist list | cut -f2 | ${config.wm.dmenu} | wl-copy
        '';
      })
    ];

    keybind.binds = [
      {
        modifiers = [
          "SUPER"
          "CTRL"
        ];
        key = "V";
        action = "clipselect";
      }
    ];
  };
}
