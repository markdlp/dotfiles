{ config, lib, pkgs, modulesPath, ... }:

{
  # Boot and Hardware settings
  boot = {
    # Use standard upstream Linux kernel (prebuilt and cached on cache.nixos.org)
    kernelPackages = pkgs.linuxPackages;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  # SD Card File System
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };
}