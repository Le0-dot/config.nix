{
  lib,
  pkgs,
  config,
  hostName,
  ...
}:

{
  options.services.samba = {
    users = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            password-file = lib.mkOption { type = lib.types.path; };
          };
        }
      );
      default = [ ];
      description = "List of users to create Samba accounts for.";
    };
  };

  config = lib.mkIf config.services.samba.enable {
    services.samba = {
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "${hostName} server";
          "security" = "user";
          "server min protocol" = "SMB3";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "use sendfile" = "yes";
          "aio read size" = 1;
          "aio write size" = 1;
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    system.activationScripts.samba-users.text = ''
      while IFS=':' read -r name _; do
        ${lib.getBin pkgs.samba}/bin/pdbedit -x -u "$name"
      done < <(${lib.getBin pkgs.samba}/bin/pdbedit -L)
    ''
    + builtins.concatStringsSep "\n" (
      builtins.map (
        user:
        "cat ${user.password-file} ${user.password-file} | ${lib.getBin pkgs.samba}/bin/smbpasswd -sa ${user.name}"
      ) config.services.samba.users
    );
  };
}
