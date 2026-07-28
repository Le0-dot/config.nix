# Tailscale aspect: wraps the custom NixOS module (option declarations +
# auto-generated systemd units from quadlet pod labels).
{ den, ... }:
{
  den.aspects.tailscale = {
    nixos = ../../_nixos/tailscale.nix;
  };
}
