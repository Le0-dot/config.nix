{
  den.aspects.desktop.tofi = {
    homeManager =
      { pkgs, config, ... }:
      {
        home.packages = [
          (pkgs.writeShellApplication {
            name = "clip-select";
            runtimeInputs = [
              pkgs.tofi
              pkgs.cliphist
              pkgs.wl-clipboard-rs
            ];
            text = ''
              cliphist list | tofi | cliphist decode | wl-copy
            '';
          })
          (pkgs.writeShellApplication {
            name = "repo-select";
            runtimeInputs = [
              pkgs.fd
              pkgs.git
              pkgs.gawk
              pkgs.tofi
            ];
            text = ''
              [ "$#" -ne 1 ] && echo "Set search directory argument" && exit 1

              repos=$(fd --hidden --max-depth 3 --glob '**/.git' "$1" --exec echo '{//}')
              choice=$(echo "$repos" | awk 'BEGIN { FS="/" } { print $NF }' | tofi)
              echo "$repos" | awk -v dir="$choice" 'BEGIN { FS="/" } $NF == dir { print $0 }'
            '';
          })
        ];

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
