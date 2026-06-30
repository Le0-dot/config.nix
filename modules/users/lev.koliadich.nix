# User aspect for lev.koliadich.
# During bridge phase this is a placeholder — the actual HM config
# is still built by legacy.nix. Aspects are added in Stage D.
{ den, ... }:
{
  den.aspects."lev.koliadich" = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
    ];
  };
}
