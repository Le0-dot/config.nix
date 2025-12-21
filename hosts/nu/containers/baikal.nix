{
  virtualisation.oci-containers.containers.baikal = {
    image = "docker.io/ckulka/baikal:0.10.1-nginx";
    blockDevices = [
      {
        destination = "/var/www/baikal/config";
        disk = "main";
        partition = "root";
        opts.subvol = "containers/baikal/active";
        path = "/config";
      }
      {
        destination = "/var/www/baikal/Specific";
        disk = "main";
        partition = "root";
        opts.subvol = "containers/baikal/active";
        path = "/data";
      }
    ];
    ports = [
      "9080:80"
    ];
  };
}
