{ lib, config, ... }:

{
  options.filemanager.yazi = lib.mkEnableOption "yazi";

  config = lib.mkIf config.filemanager.yazi {
    stylix.targets.yazi.enable = true;

    programs.yazi = {
      enable = true;
      settings.mgr.show_hidden = true;
    };
  };
}
