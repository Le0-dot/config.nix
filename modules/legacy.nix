{ inputs, ... }:

let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  customLib = import ../lib/default.nix { };

  # Replicate what blueprint provided as specialArgs
  flake = {
    lib = customLib;
  };

  # Replicate perSystem.self.* for home modules that reference custom packages
  perSystem = {
    self = {
      choose-repo = import ../packages/choose-repo.nix { inherit pkgs; };
      clipselect = import ../packages/clipselect.nix { inherit pkgs; };
      hyprlock = import ../packages/hyprlock.nix { inherit pkgs; };
      hyprpaper = import ../packages/hyprpaper.nix { inherit pkgs; };
    };
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

  flake.systemConfigurations.omega = inputs.system-manager.lib.makeSystemConfig {
    modules = [ ../hosts/omega/system-configuration.nix ];
    extraSpecialArgs = { inherit inputs; };
  };

  flake.homeConfigurations."lev.koliadich@omega" =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [
        ../hosts/omega/users/lev.koliadich.nix
        {
          home.username = "lev.koliadich";
          home.homeDirectory = "/home/lev.koliadich";
          home.stateVersion = "26.05";
        }
      ];
      extraSpecialArgs = { inherit inputs perSystem; };
    };
}
