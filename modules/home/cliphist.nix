{
  lib,
  config,
  perSystem,
  ...
}:

{
  config = lib.mkIf config.services.cliphist.enable {
    home.packages = [ perSystem.self.clipselect ];
  };
}
