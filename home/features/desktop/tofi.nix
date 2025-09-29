{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.features.desktop.tofi = lib.mkEnableOption "tofi";

  config = lib.mkIf config.features.desktop.tofi {
    programs.tofi = {
      enable = true;
      settings = {
        font = config.stylix.fonts.monospace.name;
        font-size = "14";

        background-color = "#${config.lib.stylix.colors.base00}AA";
        width = "100%";
        height = "100%";
        outline-width = 0;
        border-width = 0;
        padding-top = "35%";
        padding-left = "35%";
        result-spacing = 10;
        num-results = 10;

        prompt-text = "\"\"";
        placeholder-text = "Choose";
        fuzzy-match = true;
      };
    };

    services.cliphist.enable = true;
    home.packages = [
      (pkgs.writeShellApplication {
        name = "clipselect";
        runtimeInputs = [
          pkgs.wl-clipboard-rs
          pkgs.tofi
          pkgs.cliphist
        ];
        text = ''
          cliphist list | cut -f2 | tofi | wl-copy
        '';
      })
    ];

    keybind.binds = [
      {
        modifiers = [
          "SUPER"
        ];
        key = "SPACE";
        action = "tofi-drun --drun-launch=true";
      }
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
