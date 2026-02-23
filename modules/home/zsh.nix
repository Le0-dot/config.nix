{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf config.programs.zsh.enable {
    programs.zsh = {
      defaultKeymap = "emacs";
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      plugins = [
        {
          name = "fzf-tab";
          # src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
          src = pkgs.fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "v1.2.0";
            sha256 = "sha256-q26XVS/LcyZPRqDNwKKA9exgBByE0muyuNb0Bbar2lY=";
          };
        }
      ];
      initContent = ''
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      '';
      # TODO: replace with uwsm
      loginExtra = ''
        if [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
            start-desktop
        fi
      '';
    };
  };
}
