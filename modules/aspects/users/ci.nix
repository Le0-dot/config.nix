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
    };
  };
}
