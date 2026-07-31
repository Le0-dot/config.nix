{
  den,
  lib,
  config,
  inputs,
  ...
}:
let
  homeManagerModules = {
    nixos = inputs.home-manager.nixosModules.home-manager;
    systemManager = inputs.home-manager.nixosModules.home-manager;
    darwin = inputs.home-manager.darwinModules.home-manager;
  };
  userHostPath = userName: [
    "home-manager"
    "users"
    userName
  ];
  result = den.lib.home-env.makeHomeEnv {
    className = "homeManager";
    ctxName = "hm";
    optionPath = "home-manager";
    supportedOses = lib.attrNames homeManagerModules;
    getModule = { host, ... }: homeManagerModules.${host.class};
    forwardPathFn = { user, ... }: userHostPath user.userName;
    schemaIncludes = config.den.schema.hm-host.includes or [ ];
  };
in
{
  disabledModules = [ "${inputs.den}/modules/aspects/batteries/home-manager.nix" ];

  den.schema.host.imports = [ result.hostConf ];
  den.schema.host.includes = [ result.battery ];

  den.schema.user.includes = [ result.userDetect ];

  den.classes.homeManager.description = "Home Manager user environment";
  den.classes.homeManager.parentPath = userHostPath;
  den.classes.homeManager.parentArg = "osConfig";
}
