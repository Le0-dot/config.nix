{ lib, config, ... }:

{
  config = lib.mkIf config.programs.ghostty.enable {
    wm.term = "ghostty";

    stylix.targets.ghostty.enable = true;

    programs.ghostty = {
      settings = {
        font-size = 14;
        keybind = builtins.map (n: "alt+${toString n}=unbind") (lib.range 1 9);
      };
    };

    keybind.binds = [
      {
        modifiers = [ "SUPER" ];
        key = "RETURN";
        action = "ghostty";
      }
    ];
  };
}
