{ lib, config, ... }:

{
  config = lib.mkIf config.programs.starship.enable {
    stylix.targets.starship.enable = true;

    programs.starship = {
      settings = {
        format = " $directory$git_branch$git_status$character";
        add_newline = false;
        character.success_symbol = "[❯](bold green)";
        directory = {
          format = "[$path]($style)[ $read_only]($read_only_style)";
          truncation_symbol = "…/";
        };
        git_branch = {
          format = "[$symbol$branch]($style) ";
          truncation_length = 8;
        };
      };
    };
  };
}
