{
  den.aspects.nix =
    let
      config = { pkgs, ... }: {
        nix.package = pkgs.nix;
        nix.gc.automatic = true;
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    in
    {
      nixos = config;
      homeManager = config;
    };
}
