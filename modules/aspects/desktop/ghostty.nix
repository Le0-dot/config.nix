{
  den.aspects.desktop.ghostty.homeManager =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      css = pkgs.writeText "tab-style.css" ''
          tabbar tabbox {
          margin: 0;
          padding: 0;
          font-family: monospace;
        }
      '';
    in
    {
      stylix.targets.ghostty.enable = true;

      programs.ghostty = {
        enable = true;
        settings = {
          font-size = 14;
          gtk-custom-css = builtins.toString css;
          gtk-wide-tabs = false;
          keybind = [
            # "alt+g=ignore"
            # "chain=new_tab"
            # "chain=next_tab"
            # "chain=text:lazygit"
          ];
        };
      };
    };
}
