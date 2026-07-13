{
  den.aspects.terminal.neovim.homeManager =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      options.programs.neovim.config = lib.mkOption {
        type = lib.types.path;
        description = "String with path to neovim configuration directory";
        example = "/home/user/neovim-config";
      };

      config = {
        programs.neovim = {
          enable = true;
          withNodeJs = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
        };

        home.packages = [ pkgs.tree-sitter ];

        home.sessionVariables.EDITOR = lib.getExe pkgs.neovim;

        xdg.configFile."nvim/init.lua".enable = lib.mkForce false;
        xdg.configFile."nvim".source =
          lib.warn "Linking ${config.programs.neovim.config} to ${config.home.homeDirectory}/.config/nvim"
            config.lib.file.mkOutOfStoreSymlink
            config.programs.neovim.config;

        programs.git.settings.diff.tool = "vimdiff";
      };
    };
}
