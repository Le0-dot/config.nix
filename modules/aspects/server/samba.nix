# Samba aspect: wraps the custom NixOS module.
# Note: the original module uses `hostName` from blueprint's specialArgs.
# We patch it to use `config.networking.hostName` instead (set by den.batteries.hostname).
{ den, ... }:
{
  den.aspects.samba = {
    nixos = ../../_nixos/samba.nix;
  };
}
