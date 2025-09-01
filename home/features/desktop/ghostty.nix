{ lib, config, ... }:

{
  options.features.desktop.ghostty = lib.mkEnableOption "ghostty";

  config = lib.mkIf config.features.desktop.ghostty {
    stylix.targets.ghostty.enable = true;

    programs.ghostty = {
      enable = true;
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
