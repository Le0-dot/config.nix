{
  den.aspects.auto-upgrade = {
    nixos = { config, ... }: {
      system.autoUpgrade = {
        enable = true;
        flake = "github:Le0-dot/config.nix?ref=deploy/${config.networking.hostName}";
        upgrade = false;
        allowReboot = true;
        dates = "Mon *-*-* 05:00:00";
        runGarbageCollection = true;
      };
    };
  };
}
