{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
      url = "github:danth/stylix";
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
      system-manager,
      nix-system-graphics,
      home-manager,
      stylix,
      keybind,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
      homeConfigurations."lev.koliadich" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          stylix.homeModules.stylix
          keybind.homeModules.keybind
          ./home
        ];
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
