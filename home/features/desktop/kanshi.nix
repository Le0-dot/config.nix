# TODO: Try setting docked with builtin and any 2 displays
{ lib, config, ... }:

{
  options.features.desktop.kanshi = lib.mkEnableOption "kanshi";

  config = lib.mkIf config.features.desktop.kanshi {
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
          profile.name = "docked1";
          profile.outputs = [
            {
              criteria = "$BUILTIN";
              position = "960,1080";
            }
            {
              criteria = "Dell Inc. DELL P2317H V2G517BE336L";
              position = "0,0";
              mode = "1920x1080@60";
              scale = 1.0;
            }
            {
              criteria = "Dell Inc. DELL P2317H V2G517BE331L";
              position = "1920,0";
              mode = "1920x1080@60";
              scale = 1.0;
            }
          ];
        }
        {
          profile.name = "docked2";
          profile.outputs = [
            {
              criteria = "$BUILTIN";
              position = "960,1080";
            }
            {
              criteria = "Dell Inc. DELL P2319H C2J9RS2";
              position = "0,0";
              mode = "1920x1080@60";
              scale = 1.0;
            }
            {
              criteria = "Dell Inc. DELL P2319H CKW45R2";
              position = "1920,0";
              mode = "1920x1080@60";
              scale = 1.0;
            }
          ];
        }
        {
          profile.name = "docked3";
          profile.outputs = [
            {
              criteria = "$BUILTIN";
              position = "960,1080";
            }
            {
              criteria = "Dell Inc. DELL P2317H 9KFDW757216I";
              position = "0,0";
              mode = "1920x1080@60";
              scale = 1.0;
            }
            {
              criteria = "Dell Inc. DELL P2317H V2G517BAB9FL";
              position = "1920,0";
              mode = "1920x1080@60";
              scale = 1.0;
            }
          ];
        }
      ];
    };
  };
}
