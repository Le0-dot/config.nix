{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.treefmt.withConfig {
        runtimeInputs = [
          pkgs.nixfmt
          pkgs.deadnix
        ];
        settings = {
          on-unmatched = "info";
          tree-root-file = "flake.nix";
          formatter = {
            nixfmt = {
              command = "nixfmt";
              includes = [ "*.nix" ];
            };
            deadnix = {
              command = "deadnix";
              options = [
                "--edit"
                "--no-lambda-arg"
                "--no-lambda-pattern-names"
              ];
              includes = [ "*.nix" ];
            };
          };
        };
      };
    };
}
