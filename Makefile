host := $(shell [ -e "$PWD/hosts/$HOST" ] && echo "$HOST" || echo omega)
user := $(USER)

switch: home system  ## Switch all nix flake configurations

build: build-home build-system  ## Build all nix flake configurations

build-home:  ## Build home-manager configuration
	nix run "github:nix-community/home-manager" -- build --flake "$(PWD)#$(user)@$(host)"

home:  ## Switch home-manager configuration
	nix run "github:nix-community/home-manager" -- switch --flake "$(PWD)#$(user)@$(host)"

build-system:  ## Build system-manager configuration
	sudo -i nix run "github:numtide/system-manager" -- build --flake "$(PWD)#$(host)"

system:  ## Switch system-manager configuration
	sudo -i nix run "github:numtide/system-manager" -- switch --flake "$(PWD)#$(host)"

build-os: ## Build NixOS configuration
	echo "TODO"

os: ## Switch NixOS configuration
	echo "TODO"

anywhere: ## Install NixOS via nix-anywhere
	nix run "github:nix-community/nixos-anywhere" -- \
		--flake "$(PWD)#$(host)" \
		--generate-hardware-config nixos-generate-config ./hosts/$(host)/hardware-configuration.nix \
		--target-host $(user)@$(host)
