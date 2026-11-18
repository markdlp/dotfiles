{ config, ... }:

{
  flake.modules.nixos.core-common =
    { ... }:
    {
      imports = [
        config.flake.modules.nixos.core-base
        config.flake.modules.nixos.core-users
        config.flake.modules.nixos.core-zsh
        config.flake.modules.nixos.core-tmux
      ];
    };
}
