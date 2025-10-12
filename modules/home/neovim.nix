{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.programs.neovim.config = lib.mkOption {
    type = lib.types.str;
    description = "String with path to neovim configuration directory";
    example = "/home/user/neovim-config";
  };

  config = lib.mkIf config.programs.neovim.enable {
    programs.neovim = {
      withNodeJs = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    home.sessionVariables.EDITOR = "${pkgs.neovim}/bin/nvim";

    home.file.".config/nvim".source =
      lib.warn "Linking ${config.programs.neovim.config} to ${config.home.homeDirectory}/.config/nvim"
        config.lib.file.mkOutOfStoreSymlink
        config.programs.neovim.config;

    programs.git.extraConfig = {
      diff.tool = "vimdiff";
    };
  };
}
