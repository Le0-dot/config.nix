{ lib, config, ... }:
{
  options.features.cli.git = lib.mkEnableOption "git";

  config = lib.mkIf config.features.cli.git {
    programs.git = {
      enable = true;
      userEmail = "lev.koliadich@kyriba.com";
      userName = "Lev Koliadich";
      delta = {
        enable = true;
        options.side-by-side = true;
        # syntax-theme = "base16-stylix";  # TODO: Implement theme
      };
      ignores = [
        "Session.vim"
        ".envrc"
      ];
      extraConfig = {
        core = {
          autocrlf = false;
          rebase = true;
        };
        pull.rebase = true;
      };
    };
    programs.gh.enable = true;
  };
}
