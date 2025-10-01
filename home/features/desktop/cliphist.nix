{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.features.desktop.cliphist = lib.mkEnableOption "cliphist";

  config = lib.mkIf config.features.desktop.cliphist {
    services.cliphist.enable = true;
    home.packages = [
      (pkgs.writeShellApplication {
        name = "clipselect";
        runtimeInputs = [
          pkgs.wl-clipboard-rs
          pkgs.cliphist
        ];
        text = ''
          cliphist list | cut -f2 | ${config.features.desktop.dmenu} | wl-copy
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
