# NixOS + Niri + Noctalia 完整配置指南

> 本指南提供在全新电脑上配置 NixOS + Niri + Noctalia 的完整流程

## 📋 目录

1. [系统安装前的准备](#1-系统安装前的准备)
2. [NixOS 安装配置](#2-nixos-安装配置)
3. [Niri 窗口管理器配置](#3-niri-窗口管理器配置)
4. [Noctalia Shell 安装与配置](#4-noctalia-shell-安装与配置)
5. [开发环境配置](#5-开发环境配置)
6. [常见问题与故障排除](#6-常见问题与故障排除)
7. [最终验证](#7-最终验证)

---

## 1. 系统安装前的准备

### 1.1 下载 NixOS

```bash
# 下载 NixOS 官方 ISO (推荐 latest 版本)
https://nixos.org/download/

# 验证 ISO 完整性 (可选但推荐)
sha256sum -c nixos.iso.sha256
```

### 1.2 创建启动 USB

**Linux/macOS**:
```bash
# 使用 dd 命令烧录 USB (替换 /dev/sdX 为你的 USB 设备)
sudo dd if=nixos.iso of=/dev/sdX bs=4M status=progress
sync

# 安全弹出
sudo eject /dev/sdX
```

**Windows**:
```powershell
# 使用 Rufus 或 Etcher 烧录 ISO 到 USB
```

### 1.3 硬件检查清单

- ✅ 至少 2GB RAM（推荐 4GB+）
- ✅ 20GB+ 可用磁盘空间
- ✅ 支持 UEFI 的主板
- ✅ NVIDIA/AMD/Intel 显卡（建议提前准备驱动信息）
- ✅ Wi-Fi/以太网连接
- ✅ USB 3.0 接口（用于安装）

---

## 2. NixOS 安装配置

### 2.1 启动到安装环境

1. 插入 USB，启动电脑
2. 进入 BIOS/UEFI 设置
3. 启用 UEFI 模式
4. 从 USB 启动
5. 选择 "NixOS installer" 或 "NixOS"

### 2.2 磁盘分区与格式化

```bash
# 列出磁盘设备
lsblk

# 示例：配置主磁盘 /dev/nvme0n1

# 1. 创建 GPT 分区表
sudo parted /dev/nvme0n1 mklabel gpt

# 2. 创建 EFI 分区 (512MB)
sudo parted /dev/nvme0n1 mkpart ESP fat32 1MiB 513MiB
sudo mkfs.fat -F 32 /dev/nvme0n1p1

# 3. 创建根分区 (50GB)
sudo parted /dev/nvme0n1 mkpart primary ext4 513MiB 50GiB
sudo mkfs.ext4 /dev/nvme0n1p2

# 4. 创建 home 分区 (剩余空间)
sudo parted /dev/nvme0n1 mkpart primary ext4 50GiB 100%
sudo mkfs.ext4 /dev/nvme0n1p3

# 5. 挂载分区
sudo mount /dev/nvme0n1p2 /mnt
sudo mkdir /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo mkdir /mnt/home
sudo mount /dev/nvme0n1p3 /mnt/home

# 验证挂载
lsblk -f
```

### 2.3 网络配置

**有线网络**（通常自动配置）：
```bash
# 检查网络连接
ping 8.8.8.8
```

**Wi-Fi 配置**：
```bash
# 启动 wpa_supplicant
sudo wpa_supplicant -B -i wlan0 -c <(wpa_passphrase "SSID" "PASSWORD")

# 获取 IP
sudo dhclient wlan0

# 测试连接
ping 8.8.8.8
```

### 2.4 生成基础配置

```bash
# 生成初始 configuration.nix
sudo nixos-generate-config --root /mnt

# 查看生成的配置
sudo nano /mnt/etc/nixos/configuration.nix
```

### 2.5 完整配置示例

创建 `/mnt/etc/nixos/configuration.nix`：

```nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # 启用 flakes 支持
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # 基础系统配置
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 网络配置
  networking.networkmanager.enable = true;

  # 设置时区
  time.timeZone = "Asia/Shanghai";

  # 国际化配置
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # 启用 OpenGL 和 Wayland
  hardware.graphics.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # 音频支持
  sound.enable = true;
  hardware.pulseaudio.enable = false;  # 使用 PipeWire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
  };

  # 启用家目录管理
  users.musers.alice = {
    isNormalUser = true;
    home = "/home/alice";
    description = "Alice Doe";
    extraGroups = [ "wheel" "video" "audio" "input" "networkmanager" ];
    packages = with pkgs; [
      firefox
      vlc
      thunderbird
    ];
    shell = pkgs.zsh;
  };

  # 启用 flakes 和获取包缓存
  nix.registry = {
    nixpkgs.flake = pkgs;
  };

  # 安装基本软件包
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    htop
    neovim
    tmux
    zsh
    starship
  ];

  # 定期垃圾回收 (可选)
  nix.autoOptimiseStore = true;

  # 系统自动更新
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # 启用 NixOS 模块
  system.stateVersion = "24.11"; # 选择适当的版本
}
```

### 2.6 执行安装

```bash
# 安装 NixOS
sudo nixos-install

# 安装完成后重启
sudo reboot
```

---

## 3. Niri 窗口管理器配置

### 3.1 配置 NixOS 支持 Niri

编辑 `/etc/nixos/configuration.nix`，添加：

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # 添加 Noctalia NixOS 模块路径
    # 方式 1: 从本地路径导入 (如果你有代码仓库)
    # /path/to/noctalia-shell/nix/nixos-module.nix

    # 方式 2: 从 GitHub 直接导入 (推荐)
    (import (builtins.fetchTarball {
      url = "https://github.com/noctalia-dev/noctalia-shell/archive/main.tar.gz";
    })).nixosModules.default
  ];

  # ... 其他配置 ...

  # 启用 Wayland 会话 (不安装 X11)
  services.xserver.enable = false;

  # 配置 Niri
  programs.niri = {
    enable = true;
    settings = {
      # 基础 Niri 配置
      focus = {
        new-window = "last";
      };

      move = {
        modify = [ "Ctrl" "Alt" ];  # Win+Alt 移动窗口
      };

      resize = {
        modify = [ "Ctrl" "Shift" "Alt" ];  # Win+Shift+Alt 调整大小
      };

      # 布局配置
      layouts = {
        spacing = 10;
        workspace-padding = 20;
      };

      # 颜色主题
      colors = {
        bg = "#0C0D11";
        bg-alt = "#111111";
        border = "#A8AEFF";
        text = "#ffffff";
        text-dim = "#888888";
      };
    };
  };

  # 如果使用 Noctalia (推荐)
  services.noctalia-shell = {
    enable = true;
    target = "graphical-session.target";
  };

  # 安装 Niri 和依赖
  environment.systemPackages = with pkgs; [
    niri
    quickshell
    # Noctalia 运行时依赖
    brightnessctl
    cava
    cliphist
    ddcutil
    matugen
    wlsunset
    wl-clipboard
    imagemagick
  ];

  # 图形驱动配置
  # Intel 集成显卡
  hardware.graphics.enable = true;
  services.udev.extraRules = ''
    KERNEL=="card0", SUBSYSTEM=="drm", DRIVERS=="i915", TAG+="seat", TAG+="uaccess"
  '';

  # NVIDIA 独立显卡 (如果需要)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Wayland 会话管理器
  services.displayManager.sddm.enable = false;  # 禁用 SDDM
  systemd.targets.graphical-session.alwaysCompose = true;
}
```

### 3.2 重新构建系统

```bash
# 构建并切换到新配置
sudo nixos-rebuild switch

# 如果使用 flake (推荐)
sudo nixos-rebuild switch --flake /etc/nixos#hostname
```

### 3.3 创建用户配置文件

编辑 `~/.config/niri/settings.kdl`（如果使用 KDL 格式）：

```kdl
// Niri 配置文件

// 聚焦设置
focus new-window "last"

// 窗口移动 (Win+Alt)
move modify ["Control" "Alt"]

// 窗口调整大小 (Win+Shift+Alt)
resize modify ["Control" "Shift" "Alt"]

// 布局
layouts {
    // 垂直分栏
    columns

    // 间隙
    spacing 10

    // 工作区边距
    workspace-padding 20
}

// 边框
borders {
    active "#A8AEFF"
    inactive "#333333"
    width 2
}

// 颜色
colors {
    background "#0C0D11"
    background-alt "#111111"
    text "#ffffff"
    text-dim "#888888"
}

// 退出快捷键 (Ctrl+Alt+Q)
quit confirm
```

---

## 4. Noctalia Shell 安装与配置

### 4.1 使用 Flakes 安装 (推荐)

创建或编辑 `/etc/nixos/flake.nix`：

```nix
{
  description = "NixOS + Niri + Noctalia configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Noctalia Flake
    noctalia.url = "github:noctalia-dev/noctalia-shell/main";
  };

  outputs = { self, nixpkgs, noctalia, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
        in
        f pkgs
      );
    in
    {
      # NixOS 配置模块
      nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          noctalia.nixosModules.default
        ];
      };

      # Home Manager 配置 (可选)
      homeConfigurations.alice = nixpkgs.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        username = "alice";
        homeDirectory = "/home/alice";
        modules = [
          noctalia.homeModules.default
        ];
      };

      # 开发 Shell
      devShells.x86_64-linux.default = pkgs.callPackage ./shell.nix { };

      # 包覆盖
      overlays.default = final: prev: {
        noctalia-shell = noctalia.packages.x86_64-linux.default;
      };
    };
}
```

### 4.2 配置 Home Manager (可选但推荐)

创建 `/etc/nixos/home.nix`：

```nix
{ config, pkgs, ... }:

{
  # 导入 Home Manager 模块
  imports = [
    # 本地 flake
    (import (fetchTarball "https://github.com/noctalia-dev/noctalia-shell/archive/main.tar.gz")).homeModules.default
  ];

  # 配置 Noctalia
  programs.noctalia-shell = {
    enable = true;

    # 启用 systemd 服务
    systemd.enable = true;

    # 默认设置
    settings = {
      # 栏配置
      bar = {
        position = "bottom";      // top, bottom, left, right
        floating = false;
        backgroundOpacity = 0.95;
      };

      # 通用设置
      general = {
        animationSpeed = 1.5;
        radiusRatio = 1.2;
      };

      # 颜色方案
      colorSchemes = {
        darkMode = true;
        useWallpaperColors = true;
      };

      # 应用启动器
      appLauncher = {
        useApp2Unit = false;
      };

      # 网络
      network = {
        showSignal = true;
      };

      # 电池
      battery = {
        showPercentage = true;
        showTime = true;
      };

      # 音频
      audio = {
        showVolume = true;
      };

      # 亮度
      brightness = {
        showBrightness = true;
      };
    };

    # 自定义颜色
    colors = {
      mError = "#ff6b6b";
      mOnError = "#ffffff";
      mOnPrimary = "#ffffff";
      mPrimary = "#A8AEFF";
      mSecondary = "#a7a7a7";
      mSurface = "#0C0D11";
      mSurfaceVariant = "#191919";
      mOnSurface = "#e0e0e0";
      mOnSurfaceVariant = "#b0b0b0";
      mShadow = "#000000";
      mOutline = "#3c3c3c";
      mTertiary = "#d4c4fb";
      mOnTertiary = "#000000";
    };
  };

  # 安装用户包
  home.packages = with pkgs; [
    # 基础工具
    git
    neovim
    htop
    curl
    wget
    zsh
    starship
    # 浏览器
    firefox
    # 媒体
    vlc
    mpv
    # 开发
    git
    nodejs
    python3
  ];

  # 设置 zsh 为默认 shell
  programs.zsh.enable = true;
  programs.starship.enable = true;

  # Git 配置
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };

  # Home Manager 需要
  home.stateVersion = "24.11";
}
```

更新 `configuration.nix`：

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./home.nix  # 添加 Home Manager 配置
  ];

  # ... 其他配置 ...

  # 启用 Home Manager
  programs.home-manager.enable = true;

  # 启用 flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # 设置用户
  users.users.alice = {
    isNormalUser = true;
    home = "/home/alice";
    description = "Alice Doe";
    extraGroups = [ "wheel" "video" "audio" "input" "networkmanager" ];
    shell = pkgs.zsh;
  };
}
```

### 4.3 重新构建

```bash
# 使用 flake 重新构建
sudo nixos-rebuild switch --flake /etc/nixos#hostname

# 或者使用 channel
sudo nixos-rebuild switch
```

---

## 5. 开发环境配置

### 5.1 进入开发环境

```bash
# 克隆仓库到本地
git clone https://github.com/noctalia-dev/noctalia-shell.git
cd noctalia-shell

# 进入开发 Shell
nix develop

# 或者使用 flake
nix develop github:noctalia-dev/noctalia-shell
```

### 5.2 开发工具

开发环境包含以下工具：

- **alejandra** - Nix 代码格式化工具
- **statix** - Nix 代码检查器
- **deadnix** - 清理未使用的 Nix 代码
- **shfmt** - Shell 脚本格式化
- **shellcheck** - Shell 脚本检查
- **qmlfmt** - QML 格式化工具
- **lefthook** - Git 钩子管理

### 5.3 运行 Noctalia

**从源代码构建**：

```bash
# 使用 Nix 构建
nix build

# 安装到用户环境
nix profile install .

# 直接运行
./result/bin/noctalia-shell
```

**使用本地 flake**：

```bash
# 安装到用户环境
nix profile install .

# 运行
noctalia-shell
```

---

## 6. 常见问题与故障排除

### 6.1 Niri 无法启动

**问题**：Niri 启动失败

**解决方案**：
```bash
# 1. 检查日志
journalctl -xeu display-manager.service

# 2. 检查 Niri 配置
niri --check-config

# 3. 验证 Wayland 支持
echo $WAYLAND_DISPLAY
loginctl show-session $XDG_SESSION_ID -p Type

# 4. 重新安装 Niri
sudo nixos-rebuild switch
```

### 6.2 Noctalia 配置文件错误

**问题**：`~/.config/noctalia/settings.json` 格式错误

**解决方案**：
```bash
# 1. 删除损坏的配置
rm -rf ~/.config/noctalia

# 2. 重启服务
systemctl --user restart noctalia-shell.service

# 3. 使用默认配置
# 配置会自动重新生成
```

### 6.3 依赖缺失

**问题**：运行时依赖缺失

**解决方案**：
```bash
# 添加缺失依赖到 configuration.nix
environment.systemPackages = with pkgs; [
  # 核心依赖
  niri
  quickshell

  # Noctalia 依赖
  brightnessctl
  cava
  cliphist
  ddcutil
  matugen
  wlsunset
  wl-clipboard
  imagemagick

  # 你的额外包...
];

# 重新构建
sudo nixos-rebuild switch
```

### 6.4 主题不生效

**问题**：颜色主题不显示

**解决方案**：
```bash
# 1. 检查配置文件
cat ~/.config/noctalia/colors.json

# 2. 重启 Noctalia 服务
systemctl --user restart noctalia-shell.service

# 3. 检查日志
journalctl --user -u noctalia-shell.service -f
```

### 6.5 显卡驱动问题

**Intel 显卡**：
```nix
# configuration.nix
hardware.graphics.enable = true;
services.xserver.enable = false;
```

**NVIDIA 显卡**：
```nix
# configuration.nix
services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  modesetting.enable = true;
  powerManagement.enable = false;
  package = config.boot.kernelPackages.nvidiaPackages.stable;
};
```

### 6.6 网络问题

**Wi-Fi 连接失败**：
```bash
# 启用 NetworkManager
sudo nmcli device wifi connect "SSID" password "PASSWORD"

# 或使用 nmtui
sudo nmtui
```

### 6.7 权限问题

**用户组权限**：
```bash
# 确保用户在必要组中
sudo usermod -a -G video,audio,input,networkmanager $USER

# 重新登录或重启
reboot
```

---

## 7. 最终验证

### 7.1 检查服务状态

```bash
# 检查 Noctalia 服务
systemctl --user status noctalia-shell.service

# 检查 Niri
systemctl status display-manager.service

# 检查 Wayland 会话
loginctl show-session $XDG_SESSION_ID
```

### 7.2 验证配置

```bash
# 测试 Niri
niri --check-config

# 测试 Noctalia (开发模式)
cd noctalia-shell
nix run

# 检查端口 (如果使用)
netstat -tlnp | grep -E "(qml|wayland)"
```

### 7.3 测试功能

**启动顺序**：
1. 启动电脑 → 登录管理器
2. 启动 Niri → Wayland 会话开始
3. 自动启动 Noctalia → 桌面环境就绪

**功能测试**：
- ✅ 工作区切换 (Super+1-9)
- ✅ 窗口移动 (Win+Alt+方向键)
- ✅ 应用启动器 (Super+D)
- ✅ 系统托盘可见
- ✅ 主题应用正确

### 7.4 性能监控

```bash
# 监控资源使用
htop

# 检查 GPU 负载
nvidia-smi  # NVIDIA
intel_gpu_frequency  # Intel

# 监控 Wayland 性能
perf top -p $(pgrep -x niri)
```

---

## 📚 参考资源

- **NixOS 官方文档**: https://nixos.org/manual/
- **Niri 文档**: https://yalter.github.io/niri/
- **Noctalia 文档**: https://docs.noctalia.dev
- **Quickshell 文档**: https://github.com/CuarzoSoftware/Quickshell
- **Home Manager**: https://github.com/nix-community/home-manager

---

## 🎉 完成

恭喜！您现在拥有了一个完整的：
- ✅ **NixOS** - 可重现的系统配置
- ✅ **Niri** - 高性能 Wayland 窗口管理器
- ✅ **Noctalia Shell** - 美观且功能强大的桌面环境

享受您的全新 Linux 体验！

---

## 💡 提示

1. **备份配置**：定期备份 `/etc/nixos/` 目录
2. **版本控制**：将配置放入 Git 仓库
3. **更新**：使用 `nixos-rebuild switch --upgrade` 更新系统
4. **文档**：维护一份您的自定义配置文档
5. **社区**：加入 NixOS、Niri、Noctalia 社区获取帮助

---

## 📝 更新日志

- **2024-12-02**: 初始版本 - 支持 NixOS 24.11, Niri latest, Noctalia latest
- 后续更新将记录在此处

---

> 💡 **提示**：本指南基于当前版本编写，具体细节可能因软件更新而变化。
> 建议始终参考最新官方文档。
