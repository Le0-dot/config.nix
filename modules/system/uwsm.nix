{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.uwsm;
  userUnitsFromPackage =
    pkg:
    let
      unitDir = "${pkg}/share/systemd/user";
      unitFiles = builtins.readDir unitDir;
    in
    lib.mapAttrs' (
      name: _: lib.nameValuePair "systemd/user/${name}" { source = "${unitDir}/${name}"; }
    ) unitFiles;
in
{
  options.programs.uwsm = {
    enable = lib.mkEnableOption "uwsm";
    package = lib.mkPackageOption pkgs "uwsm" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.etc = userUnitsFromPackage cfg.package;
    environment.pathsToLink = [
      "/share/uwsm"
      "/share/wayland-sessions"
    ];
  };
}
