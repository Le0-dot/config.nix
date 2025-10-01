{ pkgs, config, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "project-switch";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.zellij
      ];
      text = ''
        # TODO: Close current project window
        zellij list-sessions --short --reverse \
        | ${config.features.desktop.dmenu} \
        | xargs ${config.features.desktop.term} -e zellij attach
      '';
    })
  ];

  keybind.binds = [
    {
      modifiers = [
        "SUPER"
      ];
      key = "P";
      action = "project-switch";
    }
  ];
}
