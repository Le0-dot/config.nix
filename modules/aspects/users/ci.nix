{
  den.aspects.ci = {
    nixos = { lib, pkgs, ... }: {
      users.users.ci.createHome = false;
      security.sudo.extraRules = [
        {
          users = [ "ci" ];
          runAs = "root:root";
          commands = [
            # Need only to run nixos-rebuild locally
            {
              command = lib.getExe' pkgs.nix "nix-env";
              options = [ "NOPASSWD" ];
            }
            # Need to run nixos-rebuild remotely
            {
              command = "/run/current-system/sw/bin/env";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/bin/sh";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      # Test unit to check that ci can start a single service without sudo
      systemd.services.ci-test = {
        description = "No-op unit for testing ci polkit access";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe' pkgs.coreutils "true";
        };
      };

      security.polkit.enable = true;
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              action.lookup("unit") == "ci-test.service" &&
              action.lookup("verb") == "start" &&
              subject.user == "ci") {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };
}
