{
  virtualisation.oci-containers.containers.adguardhome = {
    image = "docker.io/adguard/adguardhome:latest";
    volumes = [
      "/root/adguardhome:/opt/adguardhome/conf"
      "adguardhome-data:/opt/adguardhome/work"
    ];
    ports = [
      "3000:3000"
      "53:53/udp"
      "53:53/tcp"
    ];
  };
}
