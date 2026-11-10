{
  den.hosts = {
    nu = {
      system = "x86_64-linux";
      users.ci.classes = [ "user" ];
      disks = {
        main.device = "/dev/disk/by-id/nvme-Lexar_SSD_NM620_512GB_QFB155R004190P110W";
        data.device = "/dev/disk/by-id/nvme-ADATA_LEGEND_900_4N4221121212";
        data-mirror.device = "/dev/disk/by-id/nvme-CT2000P3PSSD8_2516E9B84F3A";
        backup.device = "/dev/disk/by-id/ata-WDC_WD30EFRX-68EUZN0_WD-WMC4N0DDEXJ2";
      };
      containers = {
        adguardhome.class = "quadlet";
        audiobookshelf.class = "quadlet";
        baikal.class = "quadlet";
        bentopdf.class = "quadlet";
        homeassistant.class = "quadlet";
        immich.class = "quadlet";
        jellyfin.class = "quadlet";
        jellyseerr.class = "quadlet";
        komga.class = "quadlet";
        ntfy.class = "quadlet";
        paperless-ngx.class = "quadlet";
        prowlarr.class = "quadlet";
        radarr.class = "quadlet";
        sonarr.class = "quadlet";
        sparkyfitness.class = "quadlet";
        transmission.class = "quadlet";
      };
    };
    tau = {
      system = "x86_64-linux";
      users.ci.classes = [ "user" ];
      disks.main.device = "/dev/sda";
      containers.nginx.class = "oci-container";
    };
    omega = {
      system = "x86_64-linux";
      class = "systemManager";
      users."lev.koliadich".classes = [ "homeManager" ];
    };
  };
}
