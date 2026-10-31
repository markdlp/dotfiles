{ ... }:

{
  flake.modules.nixos.virtualisation-docker =
    { config, lib, ... }:
    {
      # Enable the Docker daemon
      virtualisation.docker.enable = true;

      # Grant user mark permissions to communicate with the Docker daemon
      users.users.mark.extraGroups = [ "docker" ];

      # Automatically enable NVIDIA Container Toolkit if NVIDIA driver is loaded
      hardware.nvidia-container-toolkit.enable = lib.mkDefault (
        builtins.elem "nvidia" (config.services.xserver.videoDrivers or [ ])
      );
    };
}
