{ lib, ... }:

let
  keybind = lib.types.submodule {
    options = {
      modifiers = lib.mkOption {
        type = lib.types.listOf (
          lib.types.enum [
            "CTRL"
            "SHIFT"
            "ALT"
            "SUPER"
          ]
        );
        default = [ ];
        description = "List of modifier keys";
      };
      key = lib.mkOption {
        type = lib.types.str;
        description = "Single trigger key";
      };
      action = lib.mkOption {
        type = lib.types.str;
        description = "Action to execute on keybind";
      };
      type = lib.mkOption {
        type = lib.types.enum [
          "PRESS"
          "HOLD"
        ];
        default = "PRESS";
        description = "Type of keybind";
      };
    };
  };
in
{
  options.keybinds = lib.mkOption {
    type = lib.types.listOf keybind;
    default = [ ];
    example = [
      {
        modifiers = [ "SUPER" ];
        key = "F";
        action = "firefox";
      }
    ];
  };
}
