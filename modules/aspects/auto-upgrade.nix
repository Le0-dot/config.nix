{
  den.aspects.auto-upgrade = {
    nixos = {
      system.autoUpgrade = {
        enable = true;
        flake = "github:Le0-dot/config.nix";
        upgrade = false;
        allowReboot = true;
        dates = "Mon *-*-* 05:00:00";
        runGarbageCollection = true;
      };
    };
  };
}
