{ inputs, ... }:
{
  den.aspects.stylix = {
    homeManager = { pkgs, ... }: {
      imports = [ inputs.stylix.homeModules.stylix ];
      stylix = {
        enable = true;
        autoEnable = false;
        targets = {
          gtk.enable = true;
          font-packages.enable = true;
          fontconfig.enable = true;
        };
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
        fonts = {
          serif = {
            # package = pkgs.fira-sans;
            name = "Fira Sans";
          };
          sansSerif = {
            # package = pkgs.fira-sans;
            name = "Fira Sans";
          };
          monospace = {
            package = pkgs.nerd-fonts.fira-code;
            name = "FiraCode Nerd Font Mono";
          };
        };
      };
    };
  };
}
