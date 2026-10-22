{
  den.hosts.x86_64-linux.nu = {
    users.ci.classes = [ "user" ];
  };
  den.hosts.x86_64-linux.tau = {
    users.ci.classes = [ "user" ];
  };
  den.hosts.x86_64-linux.omega = {
    class = "systemManager";
    users."lev.koliadich".classes = [ "homeManager" ];
  };
}
