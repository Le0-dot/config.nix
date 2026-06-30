# system-manager custom class for omega (non-NixOS host).
#
# Den's built-in pipeline produces nixosConfigurations/darwinConfigurations.
# system-manager uses its own `makeSystemConfig` (a separate evalModules).
#
# Strategy: declare omega as a den host, override `instantiate` to call
# `makeSystemConfig` instead of `nixosSystem`, and set `intoAttr` to
# produce `flake.systemConfigurations.omega`.
#
# The aspect's `nixos` class content feeds into system-manager's module
# system (which is NixOS-module-compatible). This avoids needing a truly
# custom class — system-manager modules ARE NixOS-style modules.
#
# During bridge phase: omega.nix keeps this inert (no den.hosts entry).
# Stage D activates it by adding den.hosts + removing legacy bridge.
{ }
