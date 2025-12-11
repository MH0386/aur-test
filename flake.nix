{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*.tar.gz";
    nix-software-center = {
      url = "github:snowfallorg/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-conf-editor = {
      url = "github:snowfallorg/nixos-conf-editor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fh = {
      url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      fh,
      nix-flatpak,
      home-manager,
      nur,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
      pkgsStable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      hostNames = [
        "MohamedDesktopNixOS"
        "MohamedLaptopNixOS"
      ];
      commonModules = [
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        nur.modules.nixos.default
        ./nixos/configuration.nix
      ];
    in
    {
      nixosConfigurations = lib.pipe hostNames [
        (map (
          hostName:
          lib.nameValuePair hostName (
            lib.nixosSystem {
              inherit system;
              modules =
                commonModules
                ++ [ { networking.hostName = hostName; } ] # Sets the hostname
                ++ [ (./. + "/nixos/device/${hostName}/configuration.nix") ]; # Imports the per-host configuration.nix
              specialArgs = {
                inherit inputs;
                inherit system;
                inherit fh;
                inherit pkgsStable;
                inherit nur;
              };
            }
          )
        ))
        lib.listToAttrs
      ];
    };
}
