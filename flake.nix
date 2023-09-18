{
  description = "kevin's NixOS Flake";

  # 这是 flake.nix 的标准格式，inputs 是 flake 的依赖，outputs 是 flake 的输出
  # inputs 中的每一项依赖都会在被拉取、构建后，作为参数传递给 outputs 函数
  inputs = {
    # flake inputs 有很多种引用方式，应用最广泛的格式是:
    #     github:owner/name/reference
    # 即 github 仓库地址 + branch/commit-id/tag

    # NixOS 官方软件源，这里使用 nixos-unstable 分支
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # nvimdots
    nvimdots.url = "github:ayamir/nvimdots";

    # home-manager，用于管理用户配置
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      # `follows` 是 inputs 中的继承语法
      # 这里使 sops-nix 的 `inputs.nixpkgs` 与当前 flake 的
      # `inputs.nixpkgs` 保持一致，避免依赖的 nixpkgs 版本不一致导致问题
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  # outputs 即 flake 的所有输出，其中的 nixosConfigurations 即 NixOS 系统配置
  # flake 有很多用途，也可以有很多不同的 outputs，nixosConfigurations 只是其中一种
  #
  # outputs 是一个函数，它的参数都在 inputs 中定义，可以通过 inputs 中定义的名称来引用。
  # 比如这里的输入参数 `nixpkgs`，就是上面 inputs 中的 `nixpkgs`
  # 不过 self 是个例外，这个特殊参数指向 outputs 自身（自引用），以及 flake 根目录
  # 这里的 @ 语法将函数的参数 attribute set 取了个别名，方便在内部使用
  outputs = { self, nixpkgs, home-manager, nvimdots,  ... }@inputs: {
    # 名为 nixosConfigurations 的 outputs 会在执行 `sudo nixos-rebuild switch`
    # 时被使用，默认情况下上述命令会使用与主机 hostname 同名的 nixosConfigurations
    # 但是也可以通过 `--flake /path/to/flake/direcotry#nixos-test` 来指定
    # 在 flakes 配置文件夹中执行如下命令即可部署此配置：
    #     sudo nixos-rebuild switch --flake .#nixos-test
    # 其中 --flake 后的参数简要说明如下：
    #   1. `.` 表示使用当前文件夹的 Flakes 配置，
    #   2. `#` 后面的内容则是 nixosConfigurations 的名称
    nixosConfigurations = {
      # hostname 为 nixos-test 的主机会使用这个配置
      # 这里使用了 nixpkgs.lib.nixosSystem 函数来构建配置，
      # 后面的 attributes set 是它的参数，在 nixos 系统上使用如下命令即可部署此配置：
      #     nixos-rebuild switch --flake .#nixos-test
      "nixos-test" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # Nix 模块系统可将配置模块化，提升配置的可维护性
        #
        # modules 中每个参数，都是一个 Nix Module
        # nixpkgs manual 中有半份介绍它的文档：
        #   <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
        # 说半份是因为它的文档不全，只有一些简单的介绍（Nix 文档现状...）
        #
        # Nix Module 可以是一个 attribute set，
        # 也可以是一个返回 attribute set 的函数，如果是函数，
        # 那么它的参数就是当前的 NixOS Module 的参数.
        #
        # 根据 Nix Wiki 对 Nix modules 的描述，默认情况下，
        # Nix Module 函数的参数可以有这几个：
        #
        #  lib:     nixpkgs 自带的函数库，提供了许多操作 Nix 表达式的实用函数
        #           详见 https://nixos.org/manual/nixpkgs/stable/#id-1.4
        #  config:  当前 flake 的所有 config 参数的集合，比较常用
        #  options: 当前 flake 中所有 NixOS Modules 中定义的所有参数的集合
        #  pkgs:    一个包含所有 nixpkgs 包的集合，它也提供了许多相关的工具函数
        #           入门阶段可以认为它的默认值为 `nixpkgs.legacyPackages."${system}"`
        #           可通过 `nixpkgs.pkgs` 这个 option 来自定义 pkgs 的值
        #  modulesPath: 默认 nixpkgs 的内置 Modules 文件夹路径，
        #               常用于从 nixpkgs 中导入一些额外的模块
        #               这个参数通常都用不到，我只在制作 iso 镜像时用到过
        #
        # 如果需要传其他非默认参数，就得使用 specialArgs，你可以取消注释如下这行来启用该参数
        # specialArgs = inputs  # 将 inputs 中的参数传入所有子模块
        modules = [
          # 这里导入之前我们使用的 configuration.nix，这样旧的配置文件仍然能生效
          # 注: configuration.nix 本身也是一个 Nix Module，因此可以直接在这里导入
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
             useUserPackages = true;
             useGlobalPkgs = true;
             users.kevin = ./home-manager/home.nix;
            };
          }
          nvimdots.nixosModules
          {
            nvimdots = ./nixos/neovim;
          }
        ];
      };
    };
  };
}
