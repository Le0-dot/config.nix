{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.nil
          pkgs.gnumake
          (inputs.agenix.packages.${system}.default)
          pkgs.qt6.qtdeclarative
        ];
      };
    };
}
