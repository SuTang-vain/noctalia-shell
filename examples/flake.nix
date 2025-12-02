# Flake 配置文件
# 文件路径: /etc/nixos/flake.nix
#
# 使用方法:
#   sudo nixos-rebuild switch --flake /etc/nixos#hostname

{
  description = "NixOS + Niri + Noctalia 配置";

  # 输入源
  inputs = {
    # Nixpkgs (不稳定性版，包含最新软件包)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Noctalia Flake
    noctalia.url = "github:noctalia-dev/noctalia-shell/main";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/master";

    # 稳定版 Nixpkgs (用于部分包)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, home-manager, noctalia, ... }:
    let
      # 支持的系统架构
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # 为每个系统生成配置
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          pkgs-stable = import nixpkgs { system = system; };
        in
        f pkgs pkgs-stable
      );

      # 主机名 (根据需要修改)
      hostname = "nixos-desktop";  // 修改为你的主机名
    in
    {
      # ===== NixOS 配置 =====
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix

          # Home Manager 模块
          home-manager.nixosModules.home-manager

          # Noctalia NixOS 模块
          noctalia.nixosModules.default
        ];

        specialArgs = {
          inherit hostname;
        };
      };

      # ===== Home Manager 配置 =====
      # 用户名
      username = "alice";

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        username = username;
        homeDirectory = "/home/${username}";
        configurationImport = [ ./home.nix ];

        # 包含 Noctalia Home 模块
        extraSpecialArgs = {
          inherit noctalia;
        };
      };

      # ===== 开发 Shell =====
      # 用于开发 Noctalia
      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          # 开发工具
          alejandra  # Nix 格式化
          statix     # Nix 检查
          deadnix    # 清理未使用的 Nix 代码
          shfmt      # Shell 脚本格式化
          shellcheck # Shell 脚本检查
          lefthook   # Git 钩子

          # Qt 开发
          kdePackages.qtdeclarative
          kdePackages.qt5compat
          qt6.qtbase
          qt6.qtmultimedia
          qt6.wrapQtAppsHook

          # 构建依赖
          git
          quickshell

          # 运行依赖
          brightnessctl
          cava
          cliphist
          ddcutil
          matugen
          wlsunset
          wl-clipboard
          imagemagick
        ];
      };

      # ===== 包覆盖 =====
      overlays.default = final: prev: {
        # 使用 Noctalia 覆盖默认的 quickshell
        quickshell = final.quickshell.overrideAttrs (old: {
          # 这里可以添加自定义补丁
        });

        # 自定义包
        my-packages = final.callPackage ./my-packages.nix { };

        # 覆盖特定包
        neovim-nightly-overlay = prev.neovim-nightly-overlay or (final.fetchFromGitHub {
          owner = "nix-community";
          repo = "neovim-nightly-overlay";
          rev = "master";
          sha256 = "...";
        });
      };

      # ===== 包输出 =====
      packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.noctalia-shell;
      packages.x86_64-linux.niri = nixpkgs.legacyPackages.x86_64-linux.niri;

      # ===== 格式化器 =====
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

      # ===== 检查工具 =====
      apps.x86_64-linux.nixos-check = {
        type = "app";
        program = "${nixpkgs.legacyPackages.x86_64-linux.statix}/bin/statix";
        args = [ "check" ];
      };
    };
}
