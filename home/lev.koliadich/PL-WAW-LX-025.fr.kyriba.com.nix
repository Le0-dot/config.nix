{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "pycharm-professional" ''
      ${pkgs.jetbrains.pycharm-professional}/bin/pycharm-professional -Dawt.toolkit.name=WLToolkit
    '')
  ];
}
