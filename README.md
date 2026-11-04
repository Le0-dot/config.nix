# config.nix

Nix flake with my machine configurations, built with [den](https://github.com/denful/den).

## Deployment (GitOps)

Every deployable server has a branch named `deploy/<host>`. The branch is what the server runs:

- The [`auto-upgrade`](modules/aspects/auto-upgrade.nix) aspect points `system.autoUpgrade.flake` at
  `github:Le0-dot/config.nix?ref=deploy/<hostname>`, so a host only ever pulls its
  own branch.
- A push to `deploy/<host>` runs [`deploy.yaml`](.github/workflows/deploy.yaml). It joins the
  tailnet and starts `nixos-upgrade.service` on that host over `tailscale ssh`.

### Changing a server

1. Merge the change to `main` through a PR (`check` must pass).
2. Run the **Promote main to a host deploy branch** workflow
   ([`promote.yaml`](.github/workflows/promote.yaml)) with the `host` to update. `sha` is optional
   and defaults to the tip of `main`.
3. The workflow fast-forwards `deploy/<host>` to that commit, which triggers the
   deploy.

### Branch protection

- `main`: PR-only, squash merge, `check` required, linear history.
- `deploy/**`: cannot be created, updated or deleted, and cannot be force-pushed,
  except by repository admins. The promote workflow pushes with `OWNER_PAT`, which
  has that bypass. Nothing is merged into these branches through PRs.

## Automation

| Workflow       | Trigger                | What it does                                      |
| -------------- | ---------------------- | ------------------------------------------------- |
| [`check.yaml`](.github/workflows/check.yaml)   | PRs, push to `main`    | `nix flake check`                                 |
| [`update.yaml`](.github/workflows/update.yaml)  | Mondays, manual        | Opens a flake update PR to `main` with auto-merge |
| [`promote.yaml`](.github/workflows/promote.yaml) | manual                 | Fast-forwards `deploy/<host>` to a commit on `main` |
| [`deploy.yaml`](.github/workflows/deploy.yaml)  | push to `deploy/**`    | Starts `nixos-upgrade.service` on the host        |

