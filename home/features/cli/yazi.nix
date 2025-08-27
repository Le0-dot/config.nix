{ lib, config, ... }:

{
  options.features.cli.yazi = lib.mkEnableOption "yazi";

  config = lib.mkIf config.features.cli.yazi {
    stylix.targets.yazi.enable = true;

    programs.yazi = {
      enable = true;
      settings.mgr.show_hidden = true;
    };
  };
}
