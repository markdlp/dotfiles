{ config, pkgs, lib, ... }:

{
  # Import the hardware configuration!
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "waist";
    wireless = {
      enable = false;
      networks = {
        "Huawei_vtX9Km" = {
          psk = "Fz6Z8WxX";
        };
      };
      interfaces = [ "wlan0" ];
    };
  };

  
  # Modernize shell & core environment packages system-wide
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "docker" ];
    };
  };

  environment.systemPackages = with pkgs; [
    oh-my-posh
    git
    vim
    tmux
  ];

  # Enable SSH Daemon for headless management
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false; # Enforce key-based authentication
    };
  };

  # User Configuration
  users.users.mark = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Paste your public key string from C:\USERS\MARK\DOTFILES\windows\dot_ssh\id_ed25519.pub
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7XZohJ6RvbXJwDolb2kv66xRY9lEk2JYArs3FvNTmqmdXFmKN8mevG0cMm+i0pfY7CXgbQGArRpPIz9daOSH9bwWc/jLdVqKjyLD9VPLXVD1VlCzcCicGSK4GziRbLCiXHabSXCJL/2Wy81hCQyoUqdFls6gOQoyX3qJoIkYLV7Y+fp6OCro2kFpDR8b7TQ4Dx2D4gvr36e35ZbA9cFOGCV3i5oBV2B52ygY0IDyGmNuHOUFS4z2E/P93FsC/SZHV8t28kbnl5g9HugT1Doq2Cy50g0t535wJ/pa+r/PBwBHL5CSvL+V4FnIZ6UlEo1Awj/yZ9Mdk82O1o7G37hk4p6Wx+0LpJIjqumJNOzT89mIGSVkEUaj8oUwtCFZtAI3KTqcx0+o0E1qY+02B9bucZmQcQhEl9oVsGn/tuUNVnjRx1edEPoihYTB6yvC5EyihrEnmihadqmtnenqWy6CM1XcevboMqvmui3JPDJWNYyubdVeQR7J9QSQKgOCLvbE= marko@marksKnees" 
    ];
  };

  # Enable Docker engine for your container migrations
  virtualisation.docker.enable = true;

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "26.05"; 
}