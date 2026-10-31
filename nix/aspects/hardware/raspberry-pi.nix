{ ... }:

{
  flake.modules.nixos.hardware-rpi =
    { pkgs, ... }:
    {
      # --- FIRMWARE & HARDWARE CONFIGURATION ---
      hardware.enableRedistributableFirmware = true;

      hardware.raspberry-pi.configtxt.settings = {
        all = {
          dtparam = [
            "audio=on"
            "i2c_arm=on"
          ];
          dtoverlay = [
            "vc4-kms-v3d"
          ];
          arm_boost = true;
        };
      };

      # --- HEADLESS WIRELESS NETWORKING ---
      networking.wireless = {
        enable = true;
        interfaces = [ "wlan0" ];
        secretsFile = "/root/wireless.env";
        networks."Huawei_vtX9Km".pskRaw = "ext:WIFI_PSK";
      };

      # --- HEADLESS SSH ACCESS ---
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };

      # Raspberry Pi connectivity & headless management utilities
      environment.systemPackages = with pkgs; [
        tmux
      ];
    };
}
