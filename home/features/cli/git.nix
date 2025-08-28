{ lib, config, ... }:
{
  options.features.cli.git = lib.mkEnableOption "git";

  config = lib.mkIf config.features.cli.git {
    programs.git = {
      enable = true;
      userEmail = "lev.koliadich@kyriba.com";
      userName = "Lev Koliadich";
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
