{
  lib,
  config,
  ...
}:

{
  options.features.desktop.fuzzel = lib.mkEnableOption "fuzzel";

  config = lib.mkIf config.features.desktop.fuzzel {
    stylix.targets.fuzzel.enable = true;
    features.desktop.dmenu = "fuzzle --dmenu";

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

    keybind.binds = [
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
