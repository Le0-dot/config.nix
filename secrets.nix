let
  tau = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcRsZ9/yprfUJGcVfPdRMia6cVI+DuDdACmMLJrOoa6";
  systems = [ tau ];

  local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWPb8bgtgpMQw1+TQElFUaGFy8YL6r1aRUZWCMXsu4q";
  users = [ local ];

  all = systems ++ users;
in
{
  "secrets/tailscale-key.age".publicKeys = all;
  "secrets/admin-password.age".publicKeys = all;
}
