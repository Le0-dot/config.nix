{
  den.aspects.desktop.ghostty.homeManager = { lib, config, ... }: {
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
