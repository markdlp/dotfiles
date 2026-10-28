{ inputs, ... }:

{
  flake.modules.nixos.virtualisation-libvirt =
    { ... }:
    {
      imports = [
        inputs.NixVirt.nixosModules.default
      ];

      # Enable dconf (required for virt-manager to persist configuration)
      programs.dconf.enable = true;

      # Enable libvirt (QEMU/KVM) and software TPM
      virtualisation.libvirt.enable = true;
      virtualisation.libvirt.swtpm.enable = true;
      programs.virt-manager.enable = true;

      # Add user mark to virtualization groups
      users.users.mark.extraGroups = [
        "libvirtd"
        "kvm"
      ];
    };
}
