{
  virtualisation.oci-containers.containers.audiobookshelf-test = {
    image = "ghcr.io/advplyr/audiobookshelf:latest";
    volumes = [
      "/root/audiobooks:/audiobooks"
      "audiobookshelf-config:/config"
      "audiobookshelf-metadata:/metadata"
    ];
    ports = [ "13378:80" ];
  };
}
