{ inputs, ... }:

{
  flake.modules.nixos.virtualisation-libvirt =
    { pkgs, ... }:
    {
      imports = [
        inputs.NixVirt.nixosModules.default
      ];

      # Enable dconf (required for virt-manager to persist configuration)
      programs.dconf.enable = true;

      # Enable libvirt (QEMU/KVM) and software TPM
      virtualisation.libvirt.enable = true;
      virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
      virtualisation.libvirt.swtpm.enable = true;
      programs.virt-manager.enable = true;

      # Ensure dnsmasq is available for virtual network DHCP/DNS
      environment.systemPackages = [
        pkgs.dnsmasq
      ];

      # Add user mark to virtualization groups
      users.users.mark.extraGroups = [
        "libvirtd"
        "kvm"
      ];
    };
}
