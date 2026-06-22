{
  pkgs,
  inputs,
  flake,
  ...
}:

{
  imports = [
    inputs.nix-system-graphics.systemModules.default
    flake.modules.system.hyprlock
    flake.modules.system.uwsm
  ];

  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
    system-graphics.enable = true;

    programs.uwsm = {
      enable = true;
      # waylandCompositors = {
      #   hyprland = {
      #     prettyName = "Hyprland";
      #     comment = "Start Hyprland with UWSM";
      #     package = pkgs.hyprland;
      #   };
      # };
    };
  };
}
