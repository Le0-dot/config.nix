{
  den.aspects.tailscale = { host, ... }: {
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
