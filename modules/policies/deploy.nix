{
  den,
  lib,
  self,
  ...
}:
{
  den.aspects.deploy-nixos = host: {
    packages =
      { pkgs, ... }:
      {
        "deploy-${host}" = pkgs.writeShellApplication {
          name = "deploy-${host}";
          runtimeInputs = [ pkgs.nixos-rebuild ];
          text = ''
            nixos-rebuild switch --flake ${self}#${host} --target-host ${host} --sudo "$@"
          '';
        };
      };
  };

  den.policies.deploy-nixos =
    { host, ... }:
    den.lib.policy.include (
      lib.optional (host.class == "nixos") (den.aspects.deploy-nixos host.hostName)
    );

  den.schema.host.includes = [ den.policies.deploy-nixos ];
}
