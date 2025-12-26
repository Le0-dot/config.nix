{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.services.tailscale.services = {
    enable = lib.mkEnableOption "Tailscale Services";
    enablePods = lib.mkEnableOption "Tailscale Services for podman pods via labels";
  };

  config = lib.mkIf config.services.tailscale.enable {
    # TODO: Clear removed pods

    # system.activationScripts.tailscale-serve-clear-container-services =
    #   let
    #     desired-services = builtins.concatStringsSep "\n" (
    #       map (service: "svc:${service}") (
    #         builtins.attrNames (
    #           lib.attrsets.filterAttrs notEmptyPorts config.virtualisation.oci-containers.containers
    #         )
    #       )
    #     );
    #   in
    #   ''
    #     existing=$(${lib.getExe pkgs.tailscale} serve status -json | ${lib.getExe pkgs.jq} -r '.Services // {} | keys[]')
    #     desired="${desired-services}"
    #
    #     clear=$(comm -23 <(printf '%s\n' "$existing" | sort) <(printf '%s\n' "$desired" | sort))
    #     for service in $clear; do
    #       ${lib.getExe pkgs.tailscale} serve clear "$service" > /dev/null
    #     done
    #   '';

    system.activationScripts.tailscale-serve-pods = lib.mkIf config.services.tailscale.services.enablePods ''
      pods=$(${lib.getExe pkgs.podman} pod ls --format "{{.Name}}")
      filter='.[]["Labels"] | to_entries[] | (.key | capture("tailscale.service.(?<key>[a-z]+).https")) + {value} | [.key, .value] | join(" ")'
      for pod in $pods; do
        while read -r service port; do
          ${lib.getExe pkgs.tailscale} serve --service=svc:$service --https=443 $port > /dev/null
        done < <(${lib.getExe pkgs.podman} pod inspect "$pod" | ${lib.getExe pkgs.jq} -r "$filter")
      done
    '';
  };
}
