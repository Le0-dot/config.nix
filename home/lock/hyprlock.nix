{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.lock.hyprlock = lib.mkEnableOption "hyprlock";

  config = lib.mkIf config.lock.hyprlock {
    default.lock = lib.mkDefault "hyprlock";

    stylix.targets.hyprlock.enable = true;

    programs.hyprlock = {
      enable = true;
      package = pkgs.writeShellScriptBin "hyprlock" ''
        export LD_PRELOAD="${pkgs.sssd}/lib/libnss_sss.so.2:$LD_PRELOAD"
        exec ${pkgs.hyprlock}/bin/hyprlock "$@"
      '';
      settings = {
        general = {
          hide_cursor = true;
        };

        auth.fingerprint.enabled = true;

        background = lib.mkForce [
          {
            monitor = "";
            path = "screenshot";
            blur_passes = 3;
            blur_size = 3;
          }
        ];

        input-field = {
          monitor = "";
          size = "300, 60";
          halign = "center";
          valign = "center";
          outline_thickness = 4;
          dots_size = 0.33;
          dots_spacing = 0.2;
          dots_center = true;
          fade_on_empty = false;
          placeholder_text = "";
          hide_input = false;
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        };
      };
    };
  };
}
