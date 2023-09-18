{ config, pkgs, ... }:

{
  home.username = "kevin";
  home.homeDirectory = "/home/kevin";
  home.stateVersion = "23.05";

  home.packages = with pkgs; [ tmux ];

  imports = [
    ./apps/zsh.nix
    ./apps/nvimdots.nix
  ];
}

