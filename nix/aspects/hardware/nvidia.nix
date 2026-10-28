{ ... }:

{
  flake.modules.nixos.hardware-nvidia =
    { config, ... }:
    {
      # Enable OpenGL / Hardware Graphics
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      # Load the NVIDIA driver for Xorg and Wayland
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        # Hybrid graphics prime offload
        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          nvidiaBusId = "PCI:1:0:0";
          intelBusId = "PCI:0:2:0";
        };
      };
    };
}
