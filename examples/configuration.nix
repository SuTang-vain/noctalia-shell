# 示例 NixOS 配置
# 文件路径: /etc/nixos/configuration.nix

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      # 添加 Noctalia NixOS 模块 (从 GitHub 直接导入)
      (import (builtins.fetchTarball {
        url = "https://github.com/noctalia-dev/noctalia-shell/archive/main.tar.gz";
      })).nixosModules.default

      # 如果使用 Home Manager，也导入 home.nix
      # ./home.nix
    ];

  # ===== 基本系统配置 =====

  # 启用 flakes 支持
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # 启动加载器
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 网络配置
  networking.networkmanager.enable = true;

  # 时区
  time.timeZone = "Asia/Shanghai";  # 根据你的地区修改

  # 国际化
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # ===== 图形环境 =====

  # 不使用 X11，使用 Wayland
  services.xserver.enable = false;

  # 启用图形支持
  hardware.graphics.enable = true;

  # ===== 音频系统 =====

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
  };

  # ===== 用户配置 =====

  users.users.alice = {
    isNormalUser = true;
    home = "/home/alice";
    description = "Alice Doe";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
      "networkmanager"
      "seat"
    ];
    shell = pkgs.zsh;
  };

  # ===== Niri 配置 =====

  programs.niri.enable = true;
  programs.niri.settings = {
    focus = {
      new-window = "last";
    };

    move = {
      modify = [ "Ctrl" "Alt" ];  // Win+Alt 移动窗口
    };

    resize = {
      modify = [ "Ctrl" "Shift" "Alt" ];  // Win+Shift+Alt 调整大小
    };

    layouts = {
      spacing = 10;
      workspace-padding = 20;
    };

    colors = {
      bg = "#0C0D11";
      bg-alt = "#111111";
      border = "#A8AEFF";
      text = "#ffffff";
      text-dim = "#888888";
    };

    // 退出快捷键
    quit confirm;
  };

  # ===== Noctalia Shell 配置 =====

  services.noctalia-shell = {
    enable = true;
    package = (import (builtins.fetchTarball {
      url = "https://github.com/noctalia-dev/noctalia-shell/archive/main.tar.gz";
    })).packages.x86_64-linux.default;
    target = "graphical-session.target";
  };

  # ===== 系统包 =====

  environment.systemPackages = with pkgs; [
    # 基础工具
    git
    curl
    wget
    vim
    htop
    neovim
    tmux
    zsh
    starship

    # Niri 和 Quickshell
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

    # 浏览器
    firefox

    # 媒体
    vlc
    mpv
    pipewire-alsa
    pipewire-jack

    # 文档
    zotero
    okular

    # 开发工具
    nodejs
    python3
    go
    rustup
  ];

  # ===== 显卡驱动 =====

  # Intel 集成显卡 (默认)
  services.udev.extraRules = ''
    KERNEL=="card0", SUBSYSTEM=="drm", DRIVERS=="i915", TAG+="seat", TAG+="uaccess"
  '';

  # NVIDIA 独立显卡 (取消注释以启用)
  /*
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  */

  # ===== Wayland 会话管理 =====

  # 禁用显示管理器 (Niri 使用 swaync 或类似工具)
  services.displayManager.sddm.enable = false;

  # 启用图形会话目标
  systemd.targets.graphical-session.alwaysCompose = true;

  # ===== 系统优化 =====

  # 自动垃圾回收
  nix.autoOptimiseStore = true;

  # 自动升级
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # 垃圾收集 (每日凌晨 3 点)
  nix.gc.dates = "03:15";
  nix.gc.options = "--delete-older-than 30d";

  # ===== 版本 =====

  system.stateVersion = "24.11";  # 非常重要，请保持准确
}
