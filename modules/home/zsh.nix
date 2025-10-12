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
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];
      initContent = ''
        # zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}" # Does not work for some reason
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
