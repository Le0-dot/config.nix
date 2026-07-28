{ den, ... }:
{
  den.aspects.desktop.hyprland = {
    includes = [ den.aspects.desktop.tofi ];

    homeManager = { pkgs, ... }: {
      home.pointerCursor = {
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };

      home.packages = [
        pkgs.wireplumber
        pkgs.brightnessctl
        # perSystem.self.choose-repo
      ];

      programs.hyprshot.enable = true;
      services.hyprpolkitagent.enable = true;

      stylix.targets.hyprland.enable = true;
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        extraLuaFiles = {
          config.content = ./config.lua;
          rules.content = ./rules.lua;
          binds.content = ./binds.lua;
        };
      };
    };
  };
}
