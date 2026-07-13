{ den, ... }:

{
  den.aspects.terminal = {
    includes = [
      (den.batteries.user-shell "zsh")
      (den.batteries.unfree [ "claude-code" ])
    ];

    homeManager = { pkgs, config, ... }: {
      xdg.localBinInPath = true;

      programs.direnv.enable = true;
      programs.fd.enable = true;
      programs.fzf.enable = true;
      programs.ripgrep.enable = true;

      stylix.targets.bat.enable = true;
      programs.bat.enable = true;
      home.shellAliases.cat = "bat -p";

      programs.eza = {
        enable = true;
        colors = "always";
        icons = "auto";
      };

      programs.uv.enable = true;
      programs.ty.enable = true;
      programs.npm.enable = true;
      programs.opencode.enable = true;
      programs.claude-code.enable = true;

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
      };

      programs.atuin = {
        enable = true;
        settings = {
          dialect = "uk";
          filter_mode = "directory";
          enter_accept = true;
          style = "compact";
          show_help = false;
          show_tabs = false;
          keys.scroll_exits = false;
        };
      };
    };
  };
}
