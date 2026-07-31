{
  description = "Vanilla NixOS on OnePlus 6T (fajita)";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/569d578509928497eddc3fdbf94a799027050be4";
    };
    impermanence = {
      url = "github:nix-community/impermanence/7b1d382faf603b6d264f58627330f9faa5cba149";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      x86Pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ (import ./pkgs) ];
      };
      aarch64Pkgs = import inputs.nixpkgs {
        system = "aarch64-linux";
        config.allowUnfree = true;
        overlays = [ (import ./pkgs) ];
      };

      uboot-img = aarch64Pkgs.callPackage ./uboot.nix { };

      module = import ./module.nix inputs;
    in
    {
      packages = {
        x86_64-linux = {
          inherit uboot-img;
          fajita-install = x86Pkgs.callPackage ./pkgs/fajita-install.nix { };
        };
        aarch64-linux = {
          inherit uboot-img;
          fajita-install = aarch64Pkgs.callPackage ./pkgs/fajita-install.nix { };
        };
      };

      nixosModules.default = module;

      nixosConfigurations.fajita = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          module
          {
            oneplus-fajita = {
              enable = true;
              user = "marcus";
            };
            users.users =
              let
                # Password: 123000
                pw = "$y$j9T$9GIlW.MlYdkM4dOqtXyoa1$2tUrrg2SJMJ4z92Hj7Xj7P48DvVeEtVqED9A5Sm44a5";
              in
              {
                root.hashedPassword = pw;
                marcus = {
                  isNormalUser = true;
                  hashedPassword = pw;
                  initialHashedPassword = "$y$j9T$macjSemIfW9l003gAalB5.$1LpRma6WvwC7WwcvkwuwifLrLxcyrOuiKW70/SnC5J0";

                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAqWWPb0DqvTwAJKd0Nb/MOdplnTJgxQBSGbJkL2S+nz marcus@butterbee"
                  ];
                };
              };
            networking.hostName = "fajita";
            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "yes";
            };
            security.sudo.wheelNeedsPassword = false;

            nix.channel.enable = false;
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
              "pipe-operators"
            ];
            system.stateVersion = "26.05";
          }
        ];
      };
    };
}
