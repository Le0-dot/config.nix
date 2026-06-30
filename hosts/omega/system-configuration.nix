{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nix-system-graphics.systemModules.default
    ../../modules/_system/hyprlock.nix
    ../../modules/_system/uwsm.nix
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
