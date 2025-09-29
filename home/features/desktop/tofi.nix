{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.features.desktop.tofi = lib.mkEnableOption "tofi";

  config = lib.mkIf config.features.desktop.tofi {
    stylix.targets.tofi.enable = true;

    programs.tofi = {
      enable = true;
      settings = {
        font-size = lib.mkForce "14";

        background-color = lib.mkForce "#${config.lib.stylix.colors.base00}AA";
        default-result-background = lib.mkForce "#${config.lib.stylix.colors.base00}AA";
        width = "100%";
        height = "100%";
        outline-width = 0;
        border-width = 0;
        padding-top = "35%";
        padding-left = "35%";
        result-spacing = 10;
        num-results = 10;

        prompt-text = "\"\"";
        prompt-padding = 10;
        placeholder-text = "Choose";
        scale = true;
        hide-cursor = false;
        history = true;
        fuzzy-match = true;
        auto-accept-single = false;
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
