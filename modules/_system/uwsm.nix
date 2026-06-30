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
  mk_desktop_entry =
    name:
    {
      prettyName,
      comment,
      package,
    }:
    {
      name = "${name}-uwsm.desktop";
      package = pkgs.writeText "${name}-uwsm.desktop" ''
        [Desktop Entry]
        Name=${prettyName} (UWSM)
        Comment=${comment}
        Exec=${lib.getExe cfg.package} start -F -- ${lib.getExe package}
        Type=Application
      '';
    };
  desktopEntries = lib.mapAttrsToList mk_desktop_entry cfg.waylandCompositors;
in
{
  options.programs.uwsm = {
    enable = lib.mkEnableOption "uwsm";
    package = lib.mkPackageOption pkgs "uwsm" { };
    waylandCompositors = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              prettyName = lib.mkOption {
                type = lib.types.str;
                description = "The full name of the desktop entry file.";
              };
              comment = lib.mkOption {
                type = lib.types.str;
                description = "The comment field of the desktop entry file.";
              };
              package = lib.mkOption {
                type = lib.types.package;
                description = "The wayland-compositor package.";
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.etc = userUnitsFromPackage cfg.package;
    environment.pathsToLink = [
      "/share/uwsm"
      "/share/wayland-sessions"
    ];
    systemd.tmpfiles.rules = lib.map (
      { name, package }: "L /usr/share/wayland-sessions/${name} - - - - ${package}"
    ) desktopEntries;
  };
}
