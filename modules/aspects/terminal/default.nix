{
  den.aspects.terminal = {
    homeManager = { config, ... }: {
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

      home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

      programs.uv.enable = true;
      programs.ty.enable = true;
      programs.npm.enable = true;
      programs.opencode.enable = true;
      programs.claude-code.enable = true;
    };
  };
}
