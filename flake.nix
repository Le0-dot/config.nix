{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      blueprint = inputs.blueprint { inherit inputs; };
      containerModules = inputs.blueprint.lib.importDir ./modules/nixos/containers (
        entries: builtins.mapAttrs (_: entry: entry.path) entries
      );
      containerDefault = {
        imports = builtins.attrValues containerModules;
      };
    in
    blueprint
    // {
      nixosModules = blueprint.nixosModules // {
        containers = containerModules // {
          default = containerDefault;
        };
      };
    };
}
