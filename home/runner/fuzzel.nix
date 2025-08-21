{ lib, config, ... }:

{
  options.runner.fuzzel = lib.mkEnableOption "fuzzel";

  config = lib.mkIf config.runner.fuzzel {
    stylix.targets.fuzzel.enable = true;

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          use-bold = true;
          prompt = ''"❯   "'';
          show-actions = "yes";
          width = 50;
          line-height = 18;
        };
        border.radius = 20;
      };
    };

    keybinds = [
      {
        modifiers = [
          "SUPER"
          "SHIFT"
        ];
        key = "RETURN";
        action = "fuzzel";
      }
    ];
  };
}
