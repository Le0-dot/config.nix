{
  virtualisation.oci-containers.containers.komga = {
    image = "docker.io/gotson/komga:1.23.6";
    blockDevices = [
      {
        destination = "/config";
        disk = "main";
        partition = "root";
        opts.subvol = "containers/komga/active";
        path = "/config";
      }
      {
        destination = "/data";
        disk = "data";
        opts.subvol = "comics";
      }
    ];
    ports = [
      "25600:25600"
    ];
  };
}
