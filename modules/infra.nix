{
  den.hosts = {
    nu = {
      system = "x86_64-linux";
      users.ci.classes = [ "user" ];
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
      containers.nginx.class = "quadlet";
    };
    omega = {
      system = "x86_64-linux";
      class = "systemManager";
      users."lev.koliadich".classes = [ "homeManager" ];
    };
  };
}
