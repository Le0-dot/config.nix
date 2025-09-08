{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-legacy.url = "github:nixos/nixpkgs/nixos-24.11";

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
      nixpkgs-legacy,
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
          (final: prev: {
            stable = import nixpkgs-stable { system = prev.system; };
            legacy = import nixpkgs-legacy { system = prev.system; };
          })
        ];
      };
      homeModules = [
        stylix.homeModules.stylix
        keybind.homeModules.keybind
        ./home/features
      ];
    in
    {
      apps.${system}.default =
        let
          switch = pkgs.writeShellApplication {
            name = "switch";
            runtimeInputs = [ pkgs.busybox ];
            text = ''
              # Hopefully the nerd-fonts will be fixed someday and we wouldn't need this. 
              # if [ ! -e "$HOME/.fonts/FiraCodeNerdFont-Regular.ttf" ]; then
              #      fonturl="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
              #      busybox wget -qO- "$fonturl" | busybox unzip - -x README.md -x LICENSE -d "$HOME/.fonts"
              # fi

              nix run "github:nix-community/home-manager" -- switch --flake ${./.} && \
              sudo -i nix run "github:numtide/system-manager" -- switch --flake ${./.}
            '';
          };
        in
        {
          type = "app";
          program = "${switch}/bin/switch";
        };
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
