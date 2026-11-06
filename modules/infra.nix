{
  den.hosts = {
    nu = {
      system = "x86_64-linux";
      users.ci.classes = [ "user" ];
    };
    tau = {
      system = "x86_64-linux";
      users.ci.classes = [ "user" ];
      containers.nginx.class = "quadlet";
    };
    omega = {
      system = "x86_64-linux";
      class = "systemManager";
      users."lev.koliadich".classes = [ "homeManager" ];
    };
  };
}
