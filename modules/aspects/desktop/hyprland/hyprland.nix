{
  den.aspects.desktop.hyprland.homeManager = { pkgs, ... }: {
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
      # perSystem.self.clipselect
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
}
