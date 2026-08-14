{ den, self, ... }:
{
  den.aspects.switch-nixos =
    { host, ... }:
    {
      packages =
        { pkgs, ... }:
        {
          "switch-${host.hostName}" = pkgs.writeShellApplication {
            name = "switch-${host.hostName}";
            runtimeInputs = [ pkgs.nixos-rebuild ];
            text = ''
              nixos-rebuild switch --flake ${self}#${host.hostName} --sudo "$@"
            '';
          };
          "remote-switch-${host.hostName}" = pkgs.writeShellApplication {
            name = "remote-switch-${host.hostName}";
            runtimeInputs = [ pkgs.nixos-rebuild ];
            text = ''
              nixos-rebuild switch --flake ${self}#${host.hostName} --target-host ${host.hostName} --sudo "$@"
            '';
          };
          "boot-${host.hostName}" = pkgs.writeShellApplication {
            name = "boot-${host.hostName}";
            runtimeInputs = [ pkgs.nixos-rebuild ];
            text = ''
              nixos-rebuild boot --flake ${self}#${host.hostName} --sudo "$@"
            '';
          };
          "remote-boot-${host.hostName}" = pkgs.writeShellApplication {
            name = "remote-boot-${host.hostName}";
            runtimeInputs = [ pkgs.nixos-rebuild ];
            text = ''
              nixos-rebuild boot --flake ${self}#${host.hostName} --target-host ${host.hostName} --sudo "$@"
            '';
          };
          "remote-install-${host.hostName}" = pkgs.writeShellApplication {
            name = "remote-install-${host.hostName}";
            runtimeInputs = [ pkgs.nixos-anywhere ];
            text = ''
              	nixos-anywhere --flake ${self}#${host.hostName} --target-host ${host.hostName} "$@"
            '';
          };
        };
    };

  den.aspects.switch-system-manager = { host, ... }: {
    packages =
      { pkgs, ... }:
      {
        "switch-${host.hostName}" = pkgs.writeShellApplication {
          name = "switch-${host.hostName}";
          runtimeInputs = [ pkgs.system-manager ];
          text = ''
            system-manager switch --flake ${self}#${host.hostName} --sudo
          '';
        };
        "remote-switch-${host.hostName}" = pkgs.writeShellApplication {
          name = "remote-switch-${host.hostName}";
          runtimeInputs = [ pkgs.system-manager ];
          text = ''
            system-manager switch --flake ${self}#${host.hostName} --target-host ${host.hostName} --sudo
          '';
        };
      };
  };

  den.policies.switch =
    { host, ... }:
    let
      class-aspects = {
        nixos = den.aspects.switch-nixos;
        systemManager = den.aspects.switch-system-manager;
      };
    in
    den.lib.policy.include (class-aspects.${host.class} or { });

  den.schema.host.includes = [ den.policies.switch ];
}
