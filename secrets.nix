let
  tau = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINRWhZjwHvBxQcp13586QYmTJoXuqzdDlaEcE0PBZ5vO";
  nu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDmJel+wOrfb4ixnA5WNqR9wa9OnQzU74MODE73soDmf";

  systems = [
    tau
    nu
  ];

  local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWPb8bgtgpMQw1+TQElFUaGFy8YL6r1aRUZWCMXsu4q";
  users = [ local ];

  all = systems ++ users;
in
{
  "secrets/tailscale-key.age".publicKeys = all;
  "secrets/le0-password.age".publicKeys = all;
}
