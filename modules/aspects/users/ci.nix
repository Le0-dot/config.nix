{
  den.aspects.ci = {
    nixos = { lib, pkgs, ... }: {
      users.users.ci.createHome = false;
      security.sudo.extraRules = [
        {
          users = [ "ci" ];
          runAs = "root:root";
          commands = [
            {
              command = lib.getExe' pkgs.nix "nix-env";
              options = [ "NOPASSWD" ];
            }
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
    };
  };
}
