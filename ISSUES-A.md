# Stage A Issues

Issues encountered during execution of Stage A (bootstrap den).

## 1. import-tree imports existing NixOS/HM modules into wrong context

**Symptom:** `evalModules` fails because `modules/home/*.nix`, `modules/nixos/*.nix`,
`modules/system/*.nix` are NixOS/HM modules with `config.programs.*` references that
don't exist in den's top-level module evaluation.

**Root cause:** `import-tree` recursively imports ALL `.nix` files under `modules/`.
The existing home-manager and NixOS modules are designed for their respective module
systems, not for den's `evalModules`.

**Solution:** Rename dirs to `modules/_home/`, `modules/_nixos/`, `modules/_system/`.
`import-tree` skips any path containing `/_`.

## 2. blueprint specialArgs no longer available

**Symptom:** Host config files reference `flake.nixosModules.*`,
`flake.homeModules.*`, `flake.modules.system.*`, `flake.lib.*`, `perSystem.self.*`,
and `hostName` — all provided by blueprint's conventions.

**Root cause:** Blueprint auto-discovered modules by filesystem convention and
injected `flake`, `perSystem`, `hostName` into `specialArgs`. Den doesn't replicate
this behavior.

**Solution:** Two changes:
1. Replace `flake.*Module` imports with direct relative path imports
   (e.g., `flake.nixosModules.samba` -> `../../modules/_nixos/samba.nix`)
2. Construct mock `flake` and `perSystem` attrsets in `legacy.nix` matching the
   shape blueprint provided, and pass them via `specialArgs`/`extraSpecialArgs`.

## 3. New files invisible to Nix in dirty flake

**Symptom:** `nix flake show` fails with "Path 'modules' in the repository is not
tracked by Git."

**Root cause:** Nix flakes only see files tracked by git. New files must be at least
staged (`git add`) before Nix can access them.

**Solution:** `git add` all new and renamed files before testing.

## 4. den.homes conflicts with legacy bridge homeConfigurations

**Symptom:** `home.stateVersion` reported as "no value defined" even though it's
set in both the user module file and an inline module.

**Root cause:** `den.homes.x86_64-linux."lev.koliadich@omega" = {}` causes den's
pipeline to auto-generate a `homeConfigurations."lev.koliadich@omega"` output.
This den-generated config is empty (no aspects migrated yet), and it either
overrides or merges with the legacy bridge's manually-built entry. The den-generated
one lacks `home.stateVersion`, causing the error.

**Solution:** Remove `den.homes` from `den.nix` during the bridge phase. Only add
it back when omega's home config is fully migrated to aspects (Stage D), at which
point the legacy bridge entry for omega is also removed.

## 5. home-manager needs explicit username/homeDirectory/stateVersion

**Symptom:** `homeManagerConfiguration` fails because `home.username`,
`home.homeDirectory`, and `home.stateVersion` are not set.

**Root cause:** Blueprint automatically derived `home.username` and
`home.homeDirectory` from the filesystem path convention
(`hosts/<host>/users/<user>.nix`). The standalone `homeManagerConfiguration`
call doesn't do this — these must be set explicitly.

**Solution:** Add an inline module in the `modules` list:
```nix
{
  home.username = "lev.koliadich";
  home.homeDirectory = "/home/lev.koliadich";
  home.stateVersion = "26.05";
}
```

## 6. nixpkgs.config.allowUnfree + pkgs causes infinite recursion

**Symptom:** Setting `nixpkgs.config.allowUnfree = true` inside an HM module
while also passing `pkgs` to `homeManagerConfiguration` causes an infinite
recursion in module evaluation.

**Root cause:** When `pkgs` is passed directly to `homeManagerConfiguration`,
HM uses that pkgs instance. Setting `nixpkgs.config` inside modules triggers
HM to try to re-evaluate nixpkgs, creating a circular dependency.

**Solution:** Import nixpkgs with `config.allowUnfree = true` directly and pass
the result as `pkgs`:
```nix
pkgs = import inputs.nixpkgs {
  system = "x86_64-linux";
  config.allowUnfree = true;
};
```

## 7. Renamed _home files must be git-staged

**Symptom:** After fixing issue #4, evaluation fails with "not tracked by Git"
errors for `modules/_home/git.nix` and similar.

**Root cause:** The `modules/home/` -> `modules/_home/` rename was done via `mv`
but not all files were staged. The relative path imports in the user config
(`../../../modules/_home/git.nix`) point to the new location, but Nix can't
see unstaged files in a flake.

**Solution:** `git add -A` to stage all renames before testing.
