{
  virtualisation.oci-containers.containers.adguardhome = {
    image = "docker.io/adguard/adguardhome:latest";
    blockDevices = [
      {
        destination = "/opt/adguardhome/conf";
        disk = "main";
        partition = "root";
        opts.subvol = "containers/adguardhome/active";
        path = "/config";
      }
      {
        destination = "/opt/adguardhome/work";
        disk = "main";
        partition = "root";
        opts.subvol = "containers/adguardhome/active";
        path = "/data";
      }
    ];
    ports = [
      "3000:3000"
      "53:53/udp"
      "53:53/tcp"
    ];
  };
}
