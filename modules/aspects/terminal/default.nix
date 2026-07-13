{ den, ... }:

{
  den.aspects.terminal = {
    includes = [ (den.batteries.unfree [ "claude-code" ]) ];

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

      xdg.localBinInPath = true;

      programs.uv.enable = true;
      programs.ty.enable = true;
      programs.npm.enable = true;
      programs.opencode.enable = true;
      programs.claude-code.enable = true;
    };
  };
}
