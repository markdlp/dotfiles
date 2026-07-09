{ config, pkgs, lib, ... }:

let
  # --- YOUR VARIABLES ---
  userName = "mark";
  hostname = "waist";
  interface = "wlan0";
  
  # Inject your laptop's EXACT id_ed25519.pub string here
  
  body = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImXFh8igFfW3gIBSlTm1dmy8ikX8NrUMpVy/ehSGI5j Body2Waist"; 
  knee = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAg1tjtwMp4XNfgvzgfBWLKIaS1ovrHOrYhHp0GPrs90 Knee2Waist";
  hand = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMDs/Jo99QLSQaB60GNw+UebJGvs7RTGWSV25maJSwg Hand2Waist";
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
      enable = true;
      interfaces = [ interface ];
      
      # The new, modern secrets implementation
      secretsFile = "/root/wireless.env";
      
      # Put your actual Wi-Fi name here, and point to the external password
      networks."Huawei_vtX9Km".pskRaw = "ext:WIFI_PSK";
    };
  };

  # --- NETWORKING & DISCOVERY ---
  # Assuming you already have networking.hostName = "waist";
  services.avahi = {
    enable = true;
    # Whether to enable the mDNS NSS (Name Service Switch) plugin.
    # This allows the Pi itself to resolve other .local addresses.
    nssmdns4 = true; 
    
    publish = {
      enable = true;
      addresses = true;    # Broadcast the IP address
      workstation = true;  # Broadcast as a workstation/machine
    };
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
    gh

    # The Permanent Kitty Fix
    kitty.terminfo 

    # Modern CLI Replacements
    micro       # Intuitive, mouse-friendly terminal editor
    bat         # A modern clone of 'cat' with syntax highlighting and Git integration
    eza         # A modern replacement for 'ls' with icons and colors
    btop        # A gorgeous, highly visual resource monitor (replaces htop)
    ripgrep     # Blazing fast search tool (replaces grep)
    zoxide      # A smarter 'cd' command that learns your directories

    rpi-connect 
    rpi-connect-ota
  ];

  programs.nix-ld.enable = true;	

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Enable SSH Daemon for headless management
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false; # Enforce key-based authentication
    };
  };

  users.mutableUsers = false;
  users.users.mark = {
    isNormalUser = true;
    createHome = true;
    description = "Markos Delaportas";
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ body knee hand ];
    hashedPassword = "$6$U70FqpWC8k3ygdTR$/bDSKDzpF7Ttqtl9Yy3qDjJmEq/ZHHS1BIoZgGQS8ZxlGH0jBG/R0kGwHxHLKZSoieWjYbDHvi21G5sIOIKVJ0";
  };

  users.users.root = {
    hashedPassword = "$6$U70FqpWC8k3ygdTR$/bDSKDzpF7Ttqtl9Yy3qDjJmEq/ZHHS1BIoZgGQS8ZxlGH0jBG/R0kGwHxHLKZSoieWjYbDHvi21G5sIOIKVJ0";
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Markos Delaportas";
        email = "delaportas.markos@gmail.com"; # Update this!
      };
      init.defaultBranch = "master";
    };
  };

  nix.settings.trusted-users = [ "root" "mark" ];

  security.sudo.wheelNeedsPassword = false;

  # Enable Docker engine for your container migrations
  virtualisation.docker.enable = true;

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "26.05"; 
}
