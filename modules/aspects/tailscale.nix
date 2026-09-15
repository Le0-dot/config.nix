{
  den.aspects.tailscale = { host, ... }: {
    homeManager = { pkgs, ... }: {
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
