{ config, pkgs, lib, ... }:

let
  # --- YOUR VARIABLES ---
  userName = "mark";
  hostname = "waist";
  interface = "wlan0";
  
  # Inject your laptop's EXACT id_ed25519.pub string here
  bodyPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwIR/fq0Xuem6iOpcI5A3pkRh5th1DWa475+L3bbz3+ Body2Waist"; 
  kneesPubKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7XZohJ6RvbXJwDolb2kv66xRY9lEk2JYArs3FvNTmqmdXFmKN8mevG0cMm+i0pfY7CXgbQGArRpPIz9daOSH9bwWc/jLdVqKjyLD9VPLXVD1VlCzcCicGSK4GziRbLCiXHabSXCJL/2Wy81hCQyoUqdFls6gOQoyX3qJoIkYLV7Y+fp6OCro2kFpDR8b7TQ4Dx2D4gvr36e35ZbA9cFOGCV3i5oBV2B52ygY0IDyGmNuHOUFS4z2E/P93FsC/SZHV8t28kbnl5g9HugT1Doq2Cy50g0t535wJ/pa+r/PBwBHL5CSvL+V4FnIZ6UlEo1Awj/yZ9Mdk82O1o7G37hk4p6Wx+0LpJIjqumJNOzT89mIGSVkEUaj8oUwtCFZtAI3KTqcx0+o0E1qY+02B9bucZmQcQhEl9oVsGn/tuUNVnjRx1edEPoihYTB6yvC5EyihrEnmihadqmtnenqWy6CM1XcevboMqvmui3JPDJWNYyubdVeQR7J9QSQKgOCLvbE= marksKnees" ;
in 
{
  # Import the hardware configuration!
  imports = [
    ./hardware-configuration.nix
  ];

  # --- SYSTEM & LOCALIZATION ---
  time.timeZone = "Europe/Athens";
  
  # NEW: Force UTF-8 encoding so Zsh can calculate icon widths correctly
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    hostName = hostname;
    wireless = {
      enable = false;
      
      interfaces = [ interface ];
    
      # Tell NixOS where to find the secrets locally on the target machine
      environmentFile = "/root/wireless.env";
      
      # Use the exact variable names defined in your .env file
      networks."@WIFI_SSID@".psk = "@WIFI_PSK@";
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # --- FONTS (REQUIRED FOR OH-MY-POSH ICONS) ---
  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
    nerd-fonts.fira-code
  ];

  # Modernize shell & core environment packages system-wide
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" ];
    };
    # Natively inject Oh My Posh and the atomic theme
    promptInit = ''
      eval "$(oh-my-posh init zsh --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/atomic.omp.json)"
    '';
  };

  environment.systemPackages = with pkgs; [
    oh-my-posh
    git
    vim
    tmux

    # The Permanent Kitty Fix
    kitty.terminfo 

    # Modern CLI Replacements
    micro       # Intuitive, mouse-friendly terminal editor
    bat         # A modern clone of 'cat' with syntax highlighting and Git integration
    eza         # A modern replacement for 'ls' with icons and colors
    btop        # A gorgeous, highly visual resource monitor (replaces htop)
    ripgrep     # Blazing fast search tool (replaces grep)
    zoxide      # A smarter 'cd' command that learns your directories
  ];

  

  # Enable SSH Daemon for headless management
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true; # Enforce key-based authentication
    };
  };

  users.mutableUsers = false;
  users.users.mark = {
    isNormalUser = true;
    createHome = true;
    description = "Markos Delaportas";
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ bodyPubKey kneesPubKey ];
    hashedPassword = "$6$U70FqpWC8k3ygdTR$/bDSKDzpF7Ttqtl9Yy3qDjJmEq/ZHHS1BIoZgGQS8ZxlGH0jBG/R0kGwHxHLKZSoieWjYbDHvi21G5sIOIKVJ0";
  };

  users.users.root = {
      hashedPassword = "$6$U70FqpWC8k3ygdTR$/bDSKDzpF7Ttqtl9Yy3qDjJmEq/ZHHS1BIoZgGQS8ZxlGH0jBG/R0kGwHxHLKZSoieWjYbDHvi21G5sIOIKVJ0";
  };

  nix.settings.trusted-users = [ "root" "mark" ];

  security.sudo.wheelNeedsPassword = false;

  # Enable Docker engine for your container migrations
  virtualisation.docker.enable = true;

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "26.05"; 
}