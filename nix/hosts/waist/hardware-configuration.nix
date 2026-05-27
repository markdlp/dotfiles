{ config, lib, pkgs, modulesPath, ... }:

{
  # Boot and Hardware settings
  boot = {
    # kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
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

  # --- RASPBERRY PI HARDWARE CONFIGURATION ---
  hardware.raspberry-pi.configtxt.settings = {
    all = {
      # The module supports lists for repeated keys
      dtparam = [ 
        "audio=on" 
        "i2c_arm=on" # Example: Enable I2C 
      ];
      dtoverlay = [ 
        "vc4-kms-v3d" # Enable hardware video acceleration
      ];
      # Booleans will automatically render as 0 or 1 in the final file
      arm_boost = true;
    };
  };

  hardware.enableRedistributableFirmware = true;
}