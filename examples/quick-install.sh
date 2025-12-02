#!/usr/bin/env bash

# Noctalia + Niri + NixOS 快速安装脚本
# 使用方法: curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/quick-install.sh | bash
# 或下载后执行: bash quick-install.sh

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印函数
print_header() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        NixOS + Niri + Noctalia 快速安装向导                ║"
    echo "║                                                            ║"
    echo "║  此脚本将帮助您在 NixOS 上快速配置 Niri + Noctalia         ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${CYAN}➜ $1${NC}"
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${YELLOW}[步骤 $1]${NC} $2"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 检查是否运行在 NixOS 上
check_nixos() {
    print_step "1/6" "检查系统环境"

    if ! grep -q "NixOS" /etc/os-release 2>/dev/null; then
        print_error "检测到您未运行 NixOS！"
        echo "此脚本专为 NixOS 设计。"
        echo "请访问 https://nixos.org 获取 NixOS 安装 ISO"
        exit 1
    fi

    print_success "检测到 NixOS 系统"
}

# 检查权限
check_permissions() {
    print_step "2/6" "检查权限"

    if [[ $EUID -ne 0 ]]; then
        print_error "请以 root 权限运行此脚本！"
        echo "使用: sudo $0"
        exit 1
    fi

    print_success "权限检查通过"
}

# 获取用户信息
collect_user_info() {
    print_step "3/6" "收集配置信息"

    echo -n "请输入用户名 (默认: alice): "
    read -r USERNAME
    USERNAME=${USERNAME:-alice}

    echo -n "请输入主机名 (默认: nixos-desktop): "
    read -r HOSTNAME
    HOSTNAME=${HOSTNAME:-nixos-desktop}

    echo -n "请输入时区 (默认: Asia/Shanghai): "
    read -r TIMEZONE
    TIMEZONE=${TIMEZONE:-Asia/Shanghai}

    echo -n "是否启用 NVIDIA 驱动? [y/N]: "
    read -r ENABLE_NVIDIA
    ENABLE_NVIDIA=${ENABLE_NVIDIA:-n}

    print_success "配置信息已收集"
}

# 生成配置文件
generate_configs() {
    print_step "4/6" "生成配置文件"

    CONFIG_DIR="/etc/nixos"
    EXAMPLES_DIR="/root/noctalia-examples"

    # 创建目录
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$EXAMPLES_DIR"

    # 下载示例配置
    if command -v wget &> /dev/null; then
        wget -q https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/configuration.nix -O "$EXAMPLES_DIR/configuration.nix.template"
        wget -q https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/home.nix -O "$EXAMPLES_DIR/home.nix.template"
        wget -q https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/flake.nix -O "$EXAMPLES_DIR/flake.nix.template"
    elif command -v curl &> /dev/null; then
        curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/configuration.nix -o "$EXAMPLES_DIR/configuration.nix.template"
        curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/home.nix -o "$EXAMPLES_DIR/home.nix.template"
        curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/flake.nix -o "$EXAMPLES_DIR/flake.nix.template"
    else
        print_error "未找到 wget 或 curl，无法下载配置文件！"
        exit 1
    fi

    # 生成 configuration.nix
    cat > "$CONFIG_DIR/configuration.nix" << EOF
{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./home.nix
      (import (builtins.fetchTarball {
        url = "https://github.com/noctalia-dev/noctalia-shell/archive/main.tar.gz";
      })).nixosModules.default
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "$TIMEZONE";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  services.xserver.enable = false;
  hardware.graphics.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
  };

  users.users.$USERNAME = {
    isNormalUser = true;
    home = "/home/$USERNAME";
    description = "$USERNAME User";
    extraGroups = [ "wheel" "video" "audio" "input" "networkmanager" "seat" ];
    shell = pkgs.zsh;
  };

  programs.niri.enable = true;
  programs.niri.settings = {
    focus = { new-window = "last"; };
    move = { modify = [ "Ctrl" "Alt" ]; };
    resize = { modify = [ "Ctrl" "Shift" "Alt" ]; };
    layouts = { spacing = 10; workspace-padding = 20; };
    colors = {
      bg = "#0C0D11";
      bg-alt = "#111111";
      border = "#A8AEFF";
      text = "#ffffff";
      text-dim = "#888888";
    };
    quit confirm;
  };

  services.noctalia-shell = {
    enable = true;
    target = "graphical-session.target";
  };

$(if [[ $ENABLE_NVIDIA =~ ^[Yy]$ ]]; then
cat << 'NVIDIA'
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
NVIDIA
fi)

  environment.systemPackages = with pkgs; [
    git curl wget vim htop neovim tmux zsh starship
    niri quickshell
    brightnessctl cava cliphist ddcutil matugen wlsunset wl-clipboard imagemagick
    firefox vlc mpv pipewire-alsa pipewire-jack
    zotero okular nodejs python3 go rustup
  ];

  services.udev.extraRules = ''
    KERNEL=="card0", SUBSYSTEM=="drm", DRIVERS=="i915", TAG+="seat", TAG+="uaccess"
  '';

  systemd.targets.graphical-session.alwaysCompose = true;

  nix.autoOptimiseStore = true;
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  system.stateVersion = "24.11";
}
EOF

    # 生成 home.nix
    cat > "$CONFIG_DIR/home.nix" << EOF
{ config, pkgs, ... }:

{
  imports = [
    (import (builtins.fetchTarball {
      url = "https://github.com/noctalia-dev/noctalia-shell/archive/main.tar.gz";
    })).homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;

    settings = {
      bar = {
        position = "bottom";
        floating = false;
        backgroundOpacity = 0.95;
      };

      general = {
        animationSpeed = 1.5;
        radiusRatio = 1.2;
        blurEnabled = true;
        blurRadius = 20;
      };

      colorSchemes = {
        darkMode = true;
        useWallpaperColors = true;
      };

      appLauncher = {
        useApp2Unit = false;
        fuzzySearch = true;
      };

      network = { showSignal = true; };
      battery = { showPercentage = true; showTime = true; };
      audio = { showVolume = true; };
      brightness = { showBrightness = true; step = 5; };
      clock = { show24Hours = false; showSeconds = false; showDate = true; };
      systemMonitor = { enabled = true; showCPU = true; showRAM = true; };
      lockscreen = { enabled = true; autoLockAfter = 300; };
      notifications = { enabled = true; position = "top-right"; };
      screenshot = { enabled = true; copyToClipboard = true; };
      wallpaper = { enabled = true; randomize = true; };
    };

    colors = {
      mError = "#ff6b6b";
      mOnError = "#ffffff";
      mPrimary = "#A8AEFF";
      mOnPrimary = "#ffffff";
      mSecondary = "#a7a7a7";
      mOnSecondary = "#111111";
      mSurface = "#0C0D11";
      mOnSurface = "#e0e0e0";
      mSurfaceVariant = "#191919";
      mOnSurfaceVariant = "#b0b0b0";
      mOutline = "#3c3c3c";
      mShadow = "#000000";
      mTertiary = "#d4c4fb";
      mOnTertiary = "#000000";
    };
  };

  home.packages = with pkgs; [
    git gitui neovim htop btop curl wget ripgrep fd fzf exa bat
    alacritty zsh starship
    firefox vlc mpv spotify
    nodejs python3 go rustup
  ];

  programs.git = {
    enable = true;
    userName = "$USERNAME";
    userEmail = "$USERNAME@example.com";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "exa -la";
      gs = "git status";
      gc = "git commit";
      update = "sudo nixos-rebuild switch";
      upgrade = "sudo nixos-rebuild switch --upgrade";
    };
  };

  programs.starship = { enable = true; };

  home.username = "$USERNAME";
  home.homeDirectory = "/home/$USERNAME";
  home.stateVersion = "24.11";
}
EOF

    print_success "配置文件已生成"
    print_warning "示例配置文件已保存到 $EXAMPLES_DIR"
}

# 创建 NixOS 目录结构
setup_nixos() {
    print_step "5/6" "设置 NixOS 环境"

    # 启用 flakes (如果尚未启用)
    if [[ ! -f /etc/nixos/flake.nix ]]; then
        mkdir -p /etc/nixos
        cat > /etc/nixos/flake.nix << 'EOF'
{
  description = "NixOS + Niri + Noctalia configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    noctalia.url = "github:noctalia-dev/noctalia-shell/main";
  };

  outputs = { self, nixpkgs, noctalia }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
        let pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
        in f pkgs
      );
    in
    {
      nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration.nix ];
        specialArgs = { hostname = "nixos-desktop"; };
      };

      overlays.default = final: prev: {
        noctalia-shell = noctalia.packages.x86_64-linux.default;
      };
    };
}
EOF
        print_success "创建 flake.nix"
    fi

    # 生成硬件配置
    if [[ ! -f /etc/nixos/hardware-configuration.nix ]]; then
        nixos-generate-config --dir /etc/nixos
        print_success "生成硬件配置"
    fi

    print_success "NixOS 环境设置完成"
}

# 构建系统
build_system() {
    print_step "6/6" "构建系统配置"

    print_warning "即将构建 NixOS 配置..."
    print_warning "此操作可能需要几分钟时间，请耐心等待。"
    echo ""
    read -p "是否继续? [y/N]: " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "已取消构建。您可以稍后手动执行:"
        echo "  cd /etc/nixos"
        echo "  sudo nixos-rebuild switch --flake .#$HOSTNAME"
        exit 0
    fi

    echo ""
    print_warning "开始构建..."

    if nixos-rebuild switch --flake /etc/nixos#$HOSTNAME 2>&1 | tee /tmp/nixos-build.log; then
        print_success "系统构建成功！"
    else
        print_error "构建失败！"
        echo "查看日志: cat /tmp/nixos-build.log"
        exit 1
    fi
}

# 显示后续步骤
show_next_steps() {
    print_section "安装完成！"

    echo -e "${GREEN}✓${NC} NixOS + Niri + Noctalia 已成功安装！"
    echo ""
    echo -e "${CYAN}后续步骤：${NC}"
    echo "  1. 重启系统: ${YELLOW}sudo reboot${NC}"
    echo ""
    echo -e "${CYAN}首次启动后：${NC}"
    echo "  1. 使用 $USERNAME 账户登录"
    echo "  2. Niri 会自动启动"
    echo "  3. Noctalia 会在 Niri 启动后自动加载"
    echo ""
    echo -e "${CYAN}常用快捷键：${NC}"
    echo "  ${YELLOW}Super + D${NC}    - 应用启动器"
    echo "  ${YELLOW}Super + Enter${NC} - 打开终端"
    echo "  ${YELLOW}Super + 1-0${NC}  - 切换工作区"
    echo "  ${YELLOW}Win + Alt + 方向键${NC} - 移动窗口"
    echo "  ${YELLOW}Ctrl + Alt + Q${NC} - 退出 Niri"
    echo ""
    echo -e "${CYAN}管理命令：${NC}"
    echo "  ${YELLOW}sudo nixos-rebuild switch${NC}           - 应用配置更改"
    echo "  ${YELLOW}sudo nixos-rebuild switch --upgrade${NC} - 升级系统"
    echo ""
    echo -e "${CYAN}配置位置：${NC}"
    echo "  ${YELLOW}/etc/nixos/configuration.nix${NC} - 主配置"
    echo "  ${YELLOW}/etc/nixos/home.nix${NC}          - 用户配置"
    echo "  ${YELLOW}/etc/nixos/flake.nix${NC}         - Flake 配置"
    echo ""
    echo -e "${CYAN}文档链接：${NC}"
    echo "  ${BLUE}NixOS: https://nixos.org/manual/${NC}"
    echo "  ${BLUE}Niri: https://yalter.github.io/niri/${NC}"
    echo "  ${BLUE}Noctalia: https://docs.noctalia.dev${NC}"
    echo ""
}

# 主函数
main() {
    print_header

    check_nixos
    check_permissions
    collect_user_info
    generate_configs
    setup_nixos
    build_system
    show_next_steps
}

# 错误处理
trap 'print_error "安装过程中发生错误！"; exit 1' ERR

# 运行主函数
main

print_success "安装完成！"
