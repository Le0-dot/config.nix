{ lib, ...}:

{
  imports = [
    ./ghostty.nix
  ];

  options.default.terminal = lib.mkOption {
    type = lib.types.str;
    description = "Default terminal emulator command";
  };
}
