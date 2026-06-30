{ inputs, ... }:

let
  system = "x86_64-linux";
  customLib = import ../lib/default.nix { };

  # Replicate what blueprint provided as specialArgs
  flake = {
    lib = customLib;
  };
in
{
  flake.nixosConfigurations.nu = inputs.nixpkgs.lib.nixosSystem {
    modules = [ ../hosts/nu/configuration.nix ];
    specialArgs = {
      inherit inputs flake;
      hostName = "nu";
    };
  };
}
