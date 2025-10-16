{ lib, ... }:

{
  options.wm = {
    term = lib.mkOption {
      type = lib.types.str;
      description = "Application to run as default terminal emulator";
    };
    dmenu = lib.mkOption {
      type = lib.types.str;
      description = "Application to run as default dmenu compatible picker";
    };
    lock = lib.mkOption {
      type = lib.types.str;
      description = "Application to run as screen locker";
    };
    on-lock = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of scripts to run on session lock";
    };
    on-unlock = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of scripts to run on session unlock";
    };
  };
}
