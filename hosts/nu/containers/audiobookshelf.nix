{
  virtualisation.oci-containers.containers.audiobookshelf = {
    image = "ghcr.io/advplyr/audiobookshelf:latest";
    blockDevices = [
      {
        destination = "/config";
        disk = "main";
        partition = "root";
        opts.subvol = "containers/audiobookshelf/active";
        path = "/config";
      }
      {
        destination = "/metadata";
        disk = "main";
        partition = "root";
        opts.subvol = "containers/audiobookshelf/active";
        path = "/metadata";
      }
      {
        destination = "/audiobooks";
        disk = "data";
        opts.subvol = "audiobooks";
      }
    ];
    ports = [ "13378:80" ];
  };
}
