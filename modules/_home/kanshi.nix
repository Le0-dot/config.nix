{ lib, config, ... }:

{
  config = lib.mkIf config.services.kanshi.enable {
    services.kanshi.settings = [
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
            criteria = "$BUILTIN";
            position = "960,1080";
          }
          {
            criteria = "*";
            position = "0,0";
            mode = "1920x1080@60";
            scale = 1.0;
          }
          {
            criteria = "**";
            position = "1920,0";
            mode = "1920x1080@60";
            scale = 1.0;
          }
        ];
      }
    ];
  };
}
