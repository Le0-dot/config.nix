host := $(shell [ -e "$PWD/hosts/$HOST" ] && echo "$HOST" || echo omega)
user := $(USER)
distr := $(shell grep '^NAME' /etc/os-release | sed 's/NAME=//')

switch:  ## Switch both system and home configurations for local host
	@$(MAKE) home
	@[ "$(distr)" = "NIXOS" ] && $(MAKE) os || $(MAKE) system;

build-home:  ## Build home-manager configuration
	nix run "github:nix-community/home-manager" -- build --flake "$(PWD)#$(user)@$(host)"

home:  ## Switch home-manager configuration
	nix run "github:nix-community/home-manager" -- switch --flake "$(PWD)#$(user)@$(host)"

build-system:  ## Build system-manager configuration
	sudo -i nix run "github:numtide/system-manager" -- build --flake "$(PWD)#$(host)"

system: check-non-nixos  ## Switch system-manager configuration
	sudo -i nix run "github:numtide/system-manager" -- switch --flake "$(PWD)#$(host)"

build-os:  ## Build NixOS configuration
	nixos-rebuild build --flake "$(PWD)#$(host)"

os: check-nixos  ## Switch NixOS configuration
	nixos-rebuild switch --flake "$(PWD)#$(host)"

remote-os:  ## Switch NixOS configuration on remote host
	nixos-rebuild switch --flake "$(PWD)#$(host)" --target-host $(user)@$(host) --sudo

anywhere:  ## Install NixOS via nixos-anywhere
	nix run "github:nix-community/nixos-anywhere" -- \
		--flake "$(PWD)#$(host)" \
		--generate-hardware-config nixos-generate-config ./hosts/$(host)/hardware-configuration.nix \
		--target-host $(user)@$(host)

check-nixos:
	@if [ "$(distr)" != "NIXOS" ]; then \
		echo "This command can only be run on NixOS systems."; \
		exit 1; \
	fi

check-non-nixos:
	@if [ "$(distr)" = "NIXOS" ]; then \
		echo "This command can only be run on non NixOS systems."; \
		exit 1; \
	fi
