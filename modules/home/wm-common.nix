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
  };

  config = {
    systemd.user.targets = {
      on-session-lock = {
        Unit = {
          Description = "Session lock services";
          Requires = [ "graphical-session.target" ];
          Conflicts = [ "on-session-unlock.target" ];
        };
      };
      on-session-unlock = {
        Unit = {
          Description = "Session unlock services";
          Requires = [ "graphical-session.target" ];
          Conflicts = [ "on-session-lock.target" ];
        };
      };
    };
  };
}
