{ inputs, config, ... }:

{
  flake.nixosConfigurations."body" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./hardware-configuration.nix

      # Dendritic Aspects
      config.flake.modules.nixos.core-base
      config.flake.modules.nixos.core-users
      config.flake.modules.nixos.core-zsh
      config.flake.modules.nixos.desktop-gnome
      config.flake.modules.nixos.desktop-apps
      config.flake.modules.nixos.hardware-nvidia
      config.flake.modules.nixos.virtualisation-docker
      config.flake.modules.nixos.virtualisation-libvirt
      config.flake.modules.nixos.dev-gnuradio
      config.flake.modules.nixos.dev-java

      # Host-specific settings
      (
        { ... }:
        {
          networking.hostName = "body";
          networking.networkmanager.enable = true;

          # Bootloader
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

          # Whonix KVM & virtual machine definitions
          virtualisation.libvirt.connections."qemu:///system" = {
            networks = [
              {
                definition = ./whonix/Whonix_external_network.xml;
                active = true;
              }
              {
                definition = ./whonix/Whonix_internal_network.xml;
                active = true;
              }
            ];
            domains = [
              {
                definition = ./whonix/Whonix-Gateway.xml;
                active = false;
              }
              {
                definition = ./whonix/Whonix-Workstation.xml;
                active = false;
              }
              {
                definition = inputs.NixVirt.lib.domain.writeXML (
                  inputs.NixVirt.lib.domain.templates.linux {
                    name = "marksHat";
                    uuid = "e5f6a7b8-5555-4eee-cccc-abcdef123456";
                    memory = {
                      count = 4;
                      unit = "GiB";
                    };
                    bridge_name = "virbr1";
                    storage_vol = /var/lib/libvirt/images/marksHat.qcow2;
                  }
                );
                active = false;
              }
            ];
          };

          # SSH host aliases
          programs.ssh.extraConfig = ''
            Host myWaist
              HostName waist.local
              IdentityFile ~/.ssh/id_myWaist

            Host myHair
              HostName snf-889095.vm.okeanos.grnet.gr
              IdentityFile ~/.ssh/id_myHair
              Port 4994
          '';

          system.stateVersion = "25.11";
        }
      )
    ];
  };
}
