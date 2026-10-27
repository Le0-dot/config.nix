{
  den.aspects.ci = {
    nixos = { lib, pkgs, ... }: {
      users.users.ci.createHome = false;
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              action.lookup("unit") == "nixos-upgrade.service" &&
              action.lookup("verb") == "start" &&
              subject.user == "ci") {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };
}
