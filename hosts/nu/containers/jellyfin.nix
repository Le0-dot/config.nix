{
  virtualisation.oci-containers.containers.jellyfin = {
    image = "docker.io/jellyfin/jellyfin:10.11.5";
    blockDevices = [
      {
        destination = "/config";
        disk = "main";
        partition = "root";
        opts.subvol = "containers/jellyfin/active";
        path = "/config";
      }
      {
        destination = "/cache";
        disk = "main";
        partition = "root";
        opts.subvol = "containers/jellyfin/active";
        path = "/cache";
      }
      {
        destination = "/media/movies";
        disk = "data";
        opts.subvol = "movies";
      }
      {
        destination = "/media/shows";
        disk = "data";
        opts.subvol = "shows";
      }
      {
        destination = "/media/anime";
        disk = "data";
        opts.subvol = "anime";
      }
      # { # TODO: use youtarr or similar to download youtube content
      #   destination = "/media/youtube";
      #   disk = "data";
      #   opts.subvol = "youtube";
      # }
    ];
    devices = [ "/dev/dri:/dev/dri" ];
    ports = [
      "8096:8096"
    ];
    # networks = [ "jellyfin" ]; # TODO
  };
}
