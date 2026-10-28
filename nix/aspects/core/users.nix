{ ... }:

let
  bodyKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImXFh8igFfW3gIBSlTm1dmy8ikX8NrUMpVy/ehSGI5j Body2Waist";
  kneeKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAg1tjtwMp4XNfgvzgfBWLKIaS1ovrHOrYhHp0GPrs90 Knee2Waist";
  handKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMDs/Jo99QLSQaB60GNw+UebJGvs7RTGWSV25maJSwg Hand2Waist";

  defaultHashedPassword = "$6$U70FqpWC8k3ygdTR$/bDSKDzpF7Ttqtl9Yy3qDjJmEq/ZHHS1BIoZgGQS8ZxlGH0jBG/R0kGwHxHLKZSoieWjYbDHvi21G5sIOIKVJ0";
in
{
  flake.modules.nixos.core-users =
    { pkgs, ... }:
    {
      # --- PRIMARY USER ACCOUNT ---
      users.users.mark = {
        isNormalUser = true;
        description = "Markos Delaportas";
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        shell = pkgs.zsh;
        hashedPassword = defaultHashedPassword;
        openssh.authorizedKeys.keys = [
          bodyKey
          kneeKey
          handKey
        ];
      };

      # Root account password hash
      users.users.root = {
        hashedPassword = defaultHashedPassword;
      };

      # --- GLOBAL GIT CONFIGURATION ---
      programs.git = {
        enable = true;
        config = {
          user = {
            name = "Markos Delaportas";
            email = "delaportas.markos@gmail.com";
          };
          init.defaultBranch = "master";
        };
      };
    };
}
