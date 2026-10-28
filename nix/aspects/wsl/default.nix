{ inputs, ... }:

{
  flake.modules.nixos.wsl =
    { pkgs, ... }:
    {
      imports = [
        inputs.nixos-wsl.nixosModules.default
      ];

      # --- NIXOS ON WSL CONFIGURATION ---
      wsl = {
        enable = true;
        defaultUser = "mark";
        interop.includePath = true;

        # Official Docker Desktop integration hook
        docker-desktop.enable = true;
      };

      # Add user mark to the docker group
      users.users.mark.extraGroups = [ "docker" ];

      # --- DECLARATIVE WINDOWS CLOUD SYMLINKS ---
      system.activationScripts.wslWindowsSymlinks.text = ''
        userHome="/home/mark"
        if [ -d "$userHome" ]; then
          # AWS configuration symlink
          if [ -d "/mnt/c/Users/mark/.aws" ]; then
            ln -sfn "/mnt/c/Users/mark/.aws" "$userHome/.aws"
            chown -h mark:users "$userHome/.aws"
          fi

          # Azure configuration symlink
          if [ -d "/mnt/c/Users/mark/.azure" ]; then
            ln -sfn "/mnt/c/Users/mark/.azure" "$userHome/.azure"
            chown -h mark:users "$userHome/.azure"
          fi
        fi
      '';

      # WSL storage & volume management utilities
      environment.systemPackages = with pkgs; [
        cryptsetup
        lvm2
      ];
    };
}
