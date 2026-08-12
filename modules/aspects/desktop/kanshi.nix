{
  den.aspects.desktop.kanshi.homeManager = { lib, config, ... }: {
    services.kanshi = {
      enable = true;
      settings = [
        {
          output.criteria = "eDP-1";
          output.mode = "1920x1200@60";
          output.scale = 1.0;
          output.alias = "BUILTIN";
        }
        {
          profile.name = "default";
          profile.outputs = [ { criteria = "$BUILTIN"; } ];
        }
        {
          profile.name = "docked";
          profile.outputs = [
            {
              criteria = "*";
              position = "0,0";
              mode = "3440x1440@60";
              scale = 1.0;
            }
            {
              criteria = "$BUILTIN";
              position = "760,1440";
            }
          ];
        }
      ];
    };
  };
}
