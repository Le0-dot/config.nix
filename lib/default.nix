{ ... }:

{
  getDevice =
    config: disk: partition:
    config.disko.devices.disk.${disk}.content.partitions.${partition}.device;
  getFs =
    config: disk: partition:
    config.disko.devices.disk.${disk}.content.partitions.${partition}.content.type;
}
