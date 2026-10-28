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

      # --- FHS BINARY COMPATIBILITY FOR DOCKER DESKTOP & WSL -e ---
      # Docker Desktop invokes `wsl.exe -e test` and `wsl.exe -e whoami` directly without
      # a shell, expecting standard FHS paths (/bin and /usr/bin) to exist.
      system.activationScripts.fhsBin.text = ''
        mkdir -p /bin /usr/bin
        for b in ${pkgs.coreutils}/bin/*; do
          name=$(basename "$b")
          ln -sfn "$b" "/bin/$name"
          ln -sfn "$b" "/usr/bin/$name"
        done
        ln -sfn ${pkgs.bash}/bin/bash /bin/bash
        ln -sfn ${pkgs.bash}/bin/bash /usr/bin/bash
      '';

      systemd.tmpfiles.rules = [
        "L+ /bin/test - - - - ${pkgs.coreutils}/bin/test"
        "L+ /usr/bin/test - - - - ${pkgs.coreutils}/bin/test"
        "L+ /bin/whoami - - - - ${pkgs.coreutils}/bin/whoami"
        "L+ /usr/bin/whoami - - - - ${pkgs.coreutils}/bin/whoami"
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
        "L+ /usr/bin/bash - - - - ${pkgs.bash}/bin/bash"
      ];

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
