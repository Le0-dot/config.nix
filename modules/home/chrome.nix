{ ... }:

{
  config = {
    # TODO: Actually install and configure chrome
    keybind.binds = [
      {
        modifiers = [
          "SUPER"
        ];
        key = "f";
        action = "google-chrome";
      }
    ];
  };
}
