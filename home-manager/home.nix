{ config, pkgs, nvimdots, user, ... }:

let 
  # user = "kevin";
  # user = "${user}";
in
{
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "23.05";

  home.packages = with pkgs; [ 
    # 会话管理工具，已经在系统级添加过了
    #tmux 
    #byobu

    # 以下是一些研发工具
    # ---------------------
    # 使用最新版本问题不大？
    docker 
    helm 
    go 

    # 一个好用的k8s操作命令行
    k9s 

    # 一个好用的kubeconfig管理与切换工具
    kubecm 


    # FIXME 以下这些希望指定版本
    kubectl 
    istioctl 
    earthly 
    vault 
    # ---------------------
  ];

  imports = [
    nvimdots.nixosModules.nvimdots
    ./apps/zsh.nix
    ./apps/nvim.nix
    ./apps/nvimdots.nix
  ];
}

