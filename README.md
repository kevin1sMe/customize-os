# Customize Os

基于nix, home-manager等定制的一个系统


## 目标
* 将系统的软件以及配置声明式管理
* 将用户的软件以及配置也声明式管理

## 使用说明
进入本仓库根目录后：
```bash
sudo nixos-rebuild switch --flake .#nixos-test
```