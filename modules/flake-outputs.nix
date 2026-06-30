{ inputs, ... }:

let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
{
  flake.devShells.${system}.default = pkgs.mkShell {
    packages = [
      pkgs.nil
      pkgs.gnumake
      (inputs.agenix.packages.${system}.default)
    ];
  };

  flake.formatter.${system} = pkgs.treefmt.withConfig {
    runtimeInputs = [
      pkgs.nixfmt
      pkgs.deadnix
      pkgs.keep-sorted
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
        keep-sorted = {
          command = "keep-sorted";
          includes = [ "*" ];
        };
      };
    };
  };
}
