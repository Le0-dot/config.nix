{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    keybind = {
      url = "github:Le0-dot/keybind.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      system-manager,
      nix-system-graphics,
      home-manager,
      stylix,
      keybind,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: { stable = import nixpkgs-stable { system = prev.system; }; })
        ];
      };
      homeModules = [
        stylix.homeModules.stylix
        keybind.homeModules.keybind
        ./home/features
      ];
    in
    {
      systemConfigs.default = system-manager.lib.makeSystemConfig {
        modules = [
          ./system
          nix-system-graphics.systemModules.default
          ({
            nixpkgs.hostPlatform = system;
            system-manager.allowAnyDistro = true;
            system-graphics.enable = true;
          })
        ];
      };
      homeConfigurations = {
        "lev.koliadich" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = homeModules ++ [ ./home/profiles/work.nix ];
          extraSpecialArgs = {
            user = "lev.koliadich";
          };
        };
      };
      formatter.${system} = pkgs.treefmt.withConfig {
        runtimeInputs = with pkgs; [
          nixfmt
          deadnix
          keep-sorted
        ];
        settings = pkgs.lib.importTOML ./treefmt.toml;
      };
    };
}
