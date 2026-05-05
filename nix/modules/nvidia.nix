{ config, pkgs, ... }:

{
  # Enable OpenGL (In NixOS 24.05+, this is hardware.graphics)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Load the NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required for Wayland and modern X11
    modesetting.enable = true;

    # Enable power management. This helps with sleep/suspend stability.
    powerManagement.enable = true;
    
    # Fine-grained power management turns off the GPU completely when not in use.
    # Set to true if you want maximum battery, but false is generally more stable 
    # depending on your specific Turing/Ampere card. Start with false.
    powerManagement.finegrained = false;

    # Use the proprietary drivers. The open-source modules are improving, 
    # but the proprietary ones are still required for absolute stability.
    open = false;

    # Enable the Nvidia settings menu
    nvidiaSettings = true;

    # Opt for the stable driver branch
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Configure Optimus (Hybrid Graphics)
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # Creates the `nvidia-offload` wrapper
      };

      # !!! REPLACE THESE WITH YOUR DECIMAL BUS IDS !!!
      nvidiaBusId = "PCI:1:0:0";
      
      # If you have an Intel CPU:
      intelBusId = "PCI:0:2:0"; 
      
      # OR, if you have an AMD CPU, comment out intelBusId and use:
      # amdgpuBusId = "PCI:0:2:0"; 
    };
  };
}