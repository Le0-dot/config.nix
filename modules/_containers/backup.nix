{ pkgs, config, ... }:

let
  ntfyTopic = "http://localhost:8090/backup";
in
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

  systemd.services = {
    containers-snapshot-success-notify = {
      description = "Notify on successful containers snapshot";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Containers: created snapshots" \
          -H "Priority: low" \
          -H "Tags: white_check_mark" \
          -d 'Successfully created snapshots for containers' \
          ${ntfyTopic}
      '';
    };
    containers-snapshot-failure-notify = {
      description = "Notify on failed containers snapshot";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Containers: failed to create snapshots" \
          -H "Priority: high" \
          -H "Tags: warning" \
          -d 'Failed to create snapshots for containers' \
          ${ntfyTopic}
      '';
    };
    containers-snapshot = {
      onSuccess = [ "containers-snapshot-success-notify.service" ];
      onFailure = [ "containers-snapshot-failure-notify.service" ];
    };
    containers-upload-success-notify = {
      description = "Notify on successful containers snapshot upload";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Containers: uploaded" \
          -H "Priority: low" \
          -H "Tags: outbox_tray,inbox_tray" \
          -d 'Successfully uploaded snapshots for containers' \
          ${ntfyTopic}
      '';
    };
    containers-upload-failure-notify = {
      description = "Notify on failed containers snapshot upload";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Containers: failed to upload" \
          -H "Priority: high" \
          -H "Tags: warning,outbox_tray,inbox_tray" \
          -d 'Failed to upload snapshots for containers' \
          ${ntfyTopic}
      '';
    };
    containers-upload = {
      onSuccess = [ "containers-upload-success-notify.service" ];
      onFailure = [ "containers-upload-failure-notify.service" ];
    };
    containers-remove-success-notify = {
      description = "Notify on successful containers snapshot removal";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Containers: removed" \
          -H "Priority: low" \
          -H "Tags: wastebasket" \
          -d 'Successfully removed snapshots for containers' \
          ${ntfyTopic}
      '';
    };
    containers-remove-failure-notify = {
      description = "Notify on failed containers snapshot removal";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Containers: failed to remove" \
          -H "Priority: high" \
          -H "Tags: warning,wastebasket" \
          -d 'Failed to remove snapshots for containers' \
          ${ntfyTopic}
      '';
    };
    containers-remove = {
      onSuccess = [ "containers-remove-success-notify.service" ];
      onFailure = [ "containers-remove-failure-notify.service" ];
    };

    data-snapshot-success-notify = {
      description = "Notify on successful data snapshot";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Data: created snapshots" \
          -H "Priority: low" \
          -H "Tags: white_check_mark" \
          -d 'Successfully created snapshots for data' \
          ${ntfyTopic}
      '';
    };
    data-snapshot-failure-notify = {
      description = "Notify on failed data snapshot";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Data: failed to create snapshots" \
          -H "Priority: high" \
          -H "Tags: warning" \
          -d 'Failed to create snapshots for data' \
          ${ntfyTopic}
      '';
    };
    data-snapshot = {
      onSuccess = [ "data-snapshot-success-notify.service" ];
      onFailure = [ "data-snapshot-failure-notify.service" ];
    };
    data-upload-success-notify = {
      description = "Notify on successful data snapshot upload";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Data: uploaded" \
          -H "Priority: low" \
          -H "Tags: outbox_tray,inbox_tray" \
          -d 'Successfully uploaded snapshots for data' \
          ${ntfyTopic}
      '';
    };
    data-upload-failure-notify = {
      description = "Notify on failed data snapshot upload";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Data: failed to upload" \
          -H "Priority: high" \
          -H "Tags: warning,outbox_tray,inbox_tray" \
          -d 'Failed to upload snapshots for data' \
          ${ntfyTopic}
      '';
    };
    data-upload = {
      onSuccess = [ "data-upload-success-notify.service" ];
      onFailure = [ "data-upload-failure-notify.service" ];
    };
    data-remove-success-notify = {
      description = "Notify on successful data snapshot removal";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Data: removed" \
          -H "Priority: low" \
          -H "Tags: wastebasket" \
          -d 'Successfully removed snapshots for data' \
          ${ntfyTopic}
      '';
    };
    data-remove-failure-notify = {
      description = "Notify on failed data snapshot removal";
      path = [ pkgs.curl ];
      script = ''
        curl \
          -H "Title: Data: failed to remove" \
          -H "Priority: high" \
          -H "Tags: warning,wastebasket" \
          -d 'Failed to remove snapshots for data' \
          ${ntfyTopic}
      '';
    };
    data-remove = {
      onSuccess = [ "data-remove-success-notify.service" ];
      onFailure = [ "data-remove-failure-notify.service" ];
    };
  };
}
