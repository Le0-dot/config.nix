{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.services.tailscale.services = {
    enable = lib.mkEnableOption "Tailscale Services";
  };

  config = lib.mkIf config.services.tailscale.enable {
    systemd.services =
      let
        labels = lib.attrsets.concatMapAttrs (
          _name: pod: pod.podConfig.labels or { }
        ) config.virtualisation.quadlet.pods;
        filteredLabels = lib.attrsets.filterAttrs (
          label: value:
          lib.strings.hasPrefix "tailscale.service." label && lib.strings.hasSuffix ".https" label
        ) labels;
        serivcePorts = lib.attrsets.mapAttrs' (
          label: value:
          lib.attrsets.nameValuePair (lib.strings.removePrefix "tailscale.service." (lib.strings.removeSuffix ".https" label)) value
        ) filteredLabels;
      in
      lib.attrsets.mapAttrs' (
        service: port:
        lib.attrsets.nameValuePair "${service}-tailscale" {
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          environment = {
            TAILSCALE_SERVICE = service;
            PROXY_PORT = port;
          };
          path = [ pkgs.tailscale ];
          script = "tailscale serve --service=svc:$TAILSCALE_SERVICE --https=443 $PROXY_PORT";
          preStop = "tailscale serve drain svc:$TAILSCALE_SERVICE";
          postStop = "tailscale serve clear svc:$TAILSCALE_SERVICE";
          upheldBy = [ "${service}-pod.service" ];
          partOf = [ "${service}-pod.service" ];
          after = [ "tailscaled.service" ];
        }
      ) serivcePorts;
  };
}
