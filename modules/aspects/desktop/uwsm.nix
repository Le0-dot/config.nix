{
  den.aspects.desktop.uwsm = {
    systemManager =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.uwsm ];
        environment.pathsToLink = [
          "/share/uwsm"
          "/share/wayland-sessions"
        ];
        environment.etc =
          let
            unitDir = "${pkgs.uwsm}/share/systemd/user";
            unitFiles = builtins.readDir unitDir;
          in
          lib.mapAttrs' (
            name: _: lib.nameValuePair "systemd/user/${name}" { source = "${unitDir}/${name}"; }
          ) unitFiles;
      };
  };
}
