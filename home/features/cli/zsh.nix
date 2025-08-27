{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.sh.zsh = lib.mkEnableOption "zsh";

  config = lib.mkIf config.sh.zsh {
    default.sh = lib.mkDefault "zsh";

    programs.zsh = {
      enable = true;
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


        function yank() {
          cat $1 | wl-copy
        }

        function za() {
            local session=$(zellij list-sessions | fzf --ansi | cut -d' ' -f1)
            if ! [[ -z "$session" ]]; then
                zellij attach $session
            fi
        }
      '';
      loginExtra = ''
        if [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
            ${config.default.wm}
        fi
      '';
    };
  };
}
