{ self, ... }:
{
  den.aspects.nu.sparkyfitness = {
    nixos =
      { config, ... }:
      let
        tailnet = "spitz-mora.ts.net";
        btrfsVolume = self.lib.btrfsVolume config.disko;
        mountVolume = self.lib.mountVolume;
      in
      {
        virtualisation.quadlet =
          let
            inherit (config.virtualisation.quadlet) pods volumes;
          in
          {
            pods.sparkyfitness.podConfig = {
              publishPorts = [ "3004:80" ];
              labels = {
                "tailscale.service.sparkyfitness.https" = "3004";
              };
            };
            volumes.sparkyfitness = btrfsVolume {
              disk = "main";
              partition = "root";
              subvol = "containers/sparkyfitness/active";
            };
            containers = {
              sparkyfitness-frontend.containerConfig = {
                image = "docker.io/codewithcj/sparkyfitness:latest";
                pod = pods.sparkyfitness.ref;
                environments = {
                  SPARKY_FITNESS_SERVER_HOST = "localhost";
                  SPARKY_FITNESS_SERVER_PORT = "3010";
                };
              };
              sparkyfitness-server.containerConfig = {
                image = "docker.io/codewithcj/sparkyfitness_server:latest";
                pod = pods.sparkyfitness.ref;
                mounts = [
                  (mountVolume {
                    volume = volumes.sparkyfitness.ref;
                    subpath = "/uploads";
                    destination = "/app/SparkyFitnessServer/uploads";
                  })
                  (mountVolume {
                    volume = volumes.sparkyfitness.ref;
                    subpath = "/backup";
                    destination = "/app/SparkyFitnessServer/backup";
                  })
                ];
                environmentFiles = [ config.age.secrets.sparkyfitness.path ];
                environments = {
                  SPARKY_FITNESS_LOG_LEVEL = "ERROR";
                  SPARKY_FITNESS_DB_HOST = "localhost";
                  SPARKY_FITNESS_DB_PORT = "5432";
                  SPARKY_FITNESS_DB_NAME = "sparkyfitness_db";
                  SPARKY_FITNESS_DB_USER = "sparky";
                  SPARKY_FITNESS_DB_PASSWORD = "sparky";
                  SPARKY_FITNESS_APP_DB_USER = "sparky_app";
                  SPARKY_FITNESS_APP_DB_PASSWORD = "sparky_app";
                  SPARKY_FITNESS_SERVER_PORT = "3010";
                  SPARKY_FITNESS_FRONTEND_URL = "https://sparkyfitness.${tailnet}";
                  NODE_ENV = "production";
                };
              };
              sparkyfitness-database.containerConfig = {
                image = "docker.io/postgres:18.3-alpine";
                pod = pods.sparkyfitness.ref;
                mounts = [
                  (mountVolume {
                    volume = volumes.sparkyfitness.ref;
                    subpath = "/db";
                    destination = "/var/lib/postgresql";
                  })
                ];
                environments = {
                  POSTGRES_DB = "sparkyfitness_db";
                  POSTGRES_USER = "sparky";
                  POSTGRES_PASSWORD = "sparky";
                };
              };
            };
          };
      };
  };
}
