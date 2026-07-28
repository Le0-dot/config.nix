{
  den.aspects.desktop.tofi = {
    homeManager =
      { pkgs, config, ... }:
      let
        clipselect = pkgs.writeShellApplication {
          name = "clipselect";
          runtimeInputs = [
            pkgs.tofi
            pkgs.cliphist
            pkgs.wl-clipboard-rs
          ];
          text = ''
            cliphist list | tofi | cliphist decode | wl-copy
          '';
        };
      in
      {
        home.packages = [ clipselect ];

        programs.tofi = {
          enable = true;
          settings = {
            font = config.stylix.fonts.monospace.name;
            font-size = "14";

            width = "100%";
            height = "100%";
            outline-width = 0;
            border-width = 0;
            padding-top = "30%";
            padding-bottom = "30%";
            padding-left = "35%";
            padding-right = "35%";
            result-spacing = 10;
            clip-to-padding = true;

            prompt-text = "\"\"";
            placeholder-text = "Choose";
            fuzzy-match = true;

            background-color = "#${config.lib.stylix.colors.base00}BB";
            placeholder-color = "#${config.lib.stylix.colors.base04}";
            text-color = "#${config.lib.stylix.colors.base05}";
            selection-color = "#${config.lib.stylix.colors.base0E}";
          };
        };
      };
  };
}
