{ lib, config, ... }:

{
  options.notification.dunst = lib.mkEnableOption "dunst";

  config = lib.mkIf config.notification.dunst {
    stylix.targets.dunst.enable = true;

    services.dunst = {
      enable = true;
      settings.global = {
        follow = "keyboard";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "20x50";
        transparency = 0;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        frame_width = 3;
        gap_size = 3;
        sort = "yes";
        line_height = 0;
        markup = "full";
        format = ''
          <b>%s</b>
          %b'';
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";
        enable_recursive_icon_lookup = true;
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 128;
        sticky_history = "yes";
        history_length = 20;
        browser = "/usr/bin/xdg-open";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 10;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
    };
  };
}
