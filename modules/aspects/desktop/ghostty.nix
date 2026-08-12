{
  den.aspects.desktop.ghostty = {
    homeManager =
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
              "ctrl+shift+h=new_split:left"
              "ctrl+shift+j=new_split:down"
              "ctrl+shift+k=new_split:up"
              "ctrl+shift+l=new_split:right"
              "alt+h=goto_split:left"
              "alt+j=goto_split:down"
              "alt+k=goto_split:up"
              "alt+l=goto_split:right"
              # "alt+g=ignore"
              # "chain=new_tab"
              # "chain=next_tab"
              # "chain=text:lazygit"
            ];
          };
        };
      };
  };
}
