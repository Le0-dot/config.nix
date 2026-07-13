{
  den.aspects.terminal.neovim = configPath: {
    homeManager =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
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
          let
            configAbsolutePath = builtins.toPath (config.home.homeDirectory + "/" + configPath);
          in
          lib.warn "Linking ${configAbsolutePath} to ${config.home.homeDirectory}/.config/nvim"
            config.lib.file.mkOutOfStoreSymlink
            configAbsolutePath;

        programs.git.settings.diff.tool = "vimdiff";
      };
  };
}
