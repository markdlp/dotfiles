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
      };

      # WSL storage & volume management utilities
      environment.systemPackages = with pkgs; [
        cryptsetup
        lvm2
      ];
    };
}
