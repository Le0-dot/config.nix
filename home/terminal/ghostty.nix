{ lib, config, ... }:

{
  options.terminal.ghostty = lib.mkEnableOption "ghostty";

  config = lib.mkIf config.terminal.ghostty {
    default.terminal = lib.mkDefault "ghostty";

    stylix.targets.ghostty.enable = true;

    programs.ghostty = {
      enable = true;
      settings = {
        font-size = 14;
        keybind = builtins.map (n: "alt+${toString n}=unbind") (lib.range 1 9);
      };
    };
  };
}
