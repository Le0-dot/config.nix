{ den, ... }:
{
  den.aspects.omega = {
    excludes = [ den.batteries.hostname ];
    systemManager = {
      nixpkgs.config.allowUnfree = true;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
      };
      systemd.tmpfiles.rules = [
        "d /etc/profiles 0755 root root -"
        "d /etc/profiles/per-user 0755 root root -"
      ];
    };
  };
}
