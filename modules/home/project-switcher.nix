{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.programs.project-switcher.enable = lib.mkEnableOption "project-switcher";

  config = lib.mkIf config.programs.project-switcher.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "project-switch";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.zellij
        ];
        text = ''
          zellij list-sessions --short --reverse \
          | ${config.wm.dmenu} \
          | xargs ${config.wm.term} -e zellij attach
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
  };
}
