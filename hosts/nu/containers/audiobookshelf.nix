{ config, flake, ... }:

let
  btrfsVolume = flake.lib.btrfsVolume config.disko;
  mountVolume = flake.lib.mountVolume;
in
{
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) pods volumes;
    in
    {
      pods.audiobookshelf.podConfig = {
        publishPorts = [ "13378:80" ];
      };
      volumes = {
        audiobookshelf = btrfsVolume {
          disk = "main";
          partition = "root";
          subvol = "containers/audiobookshelf/active";
        };
        audiobooks = btrfsVolume {
          disk = "data";
          subvol = "audiobooks";
        };
      };
      containers.audiobookshelf-main.containerConfig = {
        image = "ghcr.io/advplyr/audiobookshelf:2.31.0";
        pod = pods.audiobookshelf.ref;
        mounts = [
          (mountVolume {
            volume = volumes.audiobookshelf.ref;
            subpath = "/config";
            destination = "/config";
          })
          (mountVolume {
            volume = volumes.audiobookshelf.ref;
            subpath = "/metadata";
            destination = "/metadata";
          })
          (mountVolume {
            volume = volumes.audiobooks.ref;
            destination = "/audiobooks";
          })
        ];
      };
    };
}
