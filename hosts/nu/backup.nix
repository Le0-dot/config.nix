{ config, ... }:

{
  services.btr-backup = {
    enable = true;
    config = {
      containers = {
        enable = true;
        device = config.disko.devices.disk.main.content.partitions.root.device;
        chdir = "containers";

        snapshot = {
          enable = true;
          onCalendar = "daily";
        };

        upload = {
          enable = true;
          onCalendar = "weekly";
          destinationDevice = config.disko.devices.disk.backup.device;
        };

        remove = {
          enable = true;
          onCalendar = "monthly";
          keepLatest = 30;
        };
      };

      data = {
        enable = true;
        device = config.disko.devices.disk.data.device;
        exclude = [ "downloads" ];

        snapshot = {
          enable = true;
          onCalendar = "daily";
        };

        upload = {
          enable = true;
          onCalendar = "weekly";
          destinationDevice = config.disko.devices.disk.backup.device;
        };

        remove = {
          enable = true;
          onCalendar = "monthly";
          keepLatest = 30;
        };
      };
    };
  };
}
