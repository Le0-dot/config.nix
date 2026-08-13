{
  den,
  lib,
  self,
  ...
}:
{
  den.aspects.deploy-nixos = { host, ... }: {
    packages = { pkgs, ... }: {
      "deploy-${host.hostName}" = pkgs.writeShellApplication {
        name = "deploy-${host.hostName}";
        runtimeInputs = [ pkgs.nixos-rebuild ];
        text = ''
          nixos-rebuild switch --flake ${self}#${host.hostName} --target-host ${host.hostName} --sudo "$@"
        '';
      };
    };
  };

  den.policies.deploy-nixos =
    { host, ... }:
    den.lib.policy.include (lib.optional (host.class == "nixos") den.aspects.deploy-nixos);

  den.schema.host.includes = [ den.policies.deploy-nixos ];
}
