{ config, pkgs, ... }:

{
  imports = [
    ../../modules/nvidia.nix  # Add this line
  ];

# Bootloader, Networking, Timezone, etc.
  networking.hostName = "omen";
  
  # Define your user account
  users.users.yourusername = {
    isNormalUser = true;
    description = "My User";
    extraGroups = [ "networkmanager" "wheel" ];
    
    # Install user-specific packages here without home-manager!
    packages = with pkgs; [
      firefox
      git
      kitty
    ];
  };

  # Install system-wide packages here
  environment.systemPackages = with pkgs; [
    neovim
    wget
  ];

  system.stateVersion = "24.05"; # Adjust to your current version
}