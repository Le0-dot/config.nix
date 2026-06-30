{ lib, config, ... }:

{
  programs.atuin = lib.mkIf config.programs.atuin.enable {
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
}
