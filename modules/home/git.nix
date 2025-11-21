{ lib, config, ... }:

{
  config = lib.mkIf config.programs.git.enable {
    programs.git = {
      ignores = [
        "Session.vim"
        ".envrc"
      ];
      extraConfig = {
        init.defaultBranch = "main";
        core.autocrlf = false;
        core.rebase = true;
        pull.rebase = true;
        rerere.enabled = true;
      };
    };
  };
}
