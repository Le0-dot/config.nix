{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.features.cli.neovim = {
    enable = lib.mkEnableOption "neovim";
    config = lib.mkOption {
      type = lib.types.str;
      description = "String with path to neovim config directory";
      example = "/home/user/neovim-config";
    };
  };

  config = lib.mkIf config.features.cli.neovim.enable {
    programs.neovim = {
      enable = true;
    };

    home.sessionVariables.EDITOR = "${pkgs.neovim}/bin/nvim";

    home.shellAliases = {
      vim = "nvim";
      v = "nvim";
    };

    home.file.".config/nvim".source =
      lib.warn "Linking ${config.features.cli.neovim.config} to ~/.config/nvim"
        config.lib.file.mkOutOfStoreSymlink
        config.features.cli.neovim.config;
  };
}
