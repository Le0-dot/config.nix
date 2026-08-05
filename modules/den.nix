{ lib, inputs, ... }:
{
  imports = [ inputs.den.flakeModule ];
  systems = lib.systems.flakeExposed;
}
