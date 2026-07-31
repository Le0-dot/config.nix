{ lib, ... }:
{
  den.schema.home = { name, ... }: {
    name = lib.mkOverride 30 name; # make user@host1 != user@host2
  };
}
