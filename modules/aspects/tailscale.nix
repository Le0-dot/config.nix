{
  den.aspects.tailscale-services = {
    nixos =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      let
        servicesFromLabels =
          unit: labels:
          lib.attrsets.mapAttrs'
            (
              label: port:
              lib.attrsets.nameValuePair (lib.strings.removePrefix "tailscale.service." (
                lib.strings.removeSuffix ".https" label
              )) { inherit port unit; }
            )
            (
              lib.attrsets.filterAttrs (
                label: _: lib.strings.hasPrefix "tailscale.service." label && lib.strings.hasSuffix ".https" label
              ) labels
            );

        quadletServices = lib.attrsets.concatMapAttrs (
          name: pod: servicesFromLabels "${name}-pod.service" (pod.podConfig.labels or { })
        ) (config.virtualisation.quadlet.pods or { });

        ociServices = lib.attrsets.concatMapAttrs (
          _name: container: servicesFromLabels "${container.serviceName}.service" container.labels
        ) config.virtualisation.oci-containers.containers;

        duplicates = lib.lists.intersectLists (lib.attrNames quadletServices) (lib.attrNames ociServices);
      in
      {
        assertions = [
          {
            assertion = duplicates == [ ];
            message = "Tailscale services defined by both a quadlet pod and an oci-container: ${toString duplicates}";
          }
        ];

        systemd.services = lib.attrsets.mapAttrs' (
          service:
          { port, unit }:
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
            upheldBy = [ unit ];
            partOf = [ unit ];
            after = [ "tailscaled.service" ];
          }
        ) (quadletServices // ociServices);
      };
  };

  den.aspects.tailscale-userspace = { host, ... }: {
    homeManager =
      { pkgs, lib, ... }:
      let
        google-chrome-tailscale = pkgs.writeShellApplication {
          name = "google-chrome-tailscale";
          text = ''
            exec google-chrome \
              --user-data-dir="$HOME/.config/google-chrome-tailscale" \
              --proxy-server="socks5://localhost:1055" \
              --no-first-run \
              --no-default-browser-check \
              "$@"
          '';
        };
      in
      {
        home.packages = [ google-chrome-tailscale ];
        xdg.desktopEntries.google-chrome-tailscale = {
          name = "Google Chrome (Tailscale)";
          genericName = "Web Browser";
          comment = "Google Chrome routed through the Tailscale SOCKS5 proxy, as a separate application";
          exec = "${lib.getExe google-chrome-tailscale} %U";
          icon = "google-chrome";
          terminal = false;
          type = "Application";
          categories = [
            "Network"
            "WebBrowser"
          ];
          mimeType = [
            "text/html"
            "text/xml"
            "application/xhtml+xml"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
          ];
        };
        systemd.user.services = {
          tailscaled = {
            Unit = {
              Description = "Tailscale daemon (userspace networking)";
              After = [ "network-online.target" ];
              Wants = [ "network-online.target" ];
            };
            Service = {
              Type = "notify";
              ExecStart = ''
                ${pkgs.tailscale}/bin/tailscaled \
                  --tun=userspace-networking \
                  --socks5-server=:1055 \
                  --socket=%t/tailscale/tailscaled.sock \
                  --statedir=%h/.local/share/tailscale
              '';
              Restart = "on-failure";
            };
          };
          tailscale = {
            Unit = {
              Description = "Tailscale";
              After = [ "tailscaled.service" ];
              Requires = [ "tailscaled.service" ];
            };
            Service = {
              Type = "oneshot";
              ExecStart = ''
                ${pkgs.tailscale}/bin/tailscale --socket=%t/tailscale/tailscaled.sock up \
                  --qr \
                  --hostname=${host.hostName} \
                  --accept-routes
              '';
              ExecStop = "${pkgs.tailscale}/bin/tailscale --socket=%t/tailscale/tailscaled.sock down";
              RemainAfterExit = true;
            };
          };
        };
      };
  };
}
