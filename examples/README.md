# Noctalia + Niri + NixOS 配置示例

本目录包含在 NixOS 上快速配置 Niri + Noctalia 的完整示例文件。

## 📁 文件说明

| 文件 | 用途 | 路径 |
|------|------|------|
| `configuration.nix` | NixOS 主配置文件 | `/etc/nixos/configuration.nix` |
| `home.nix` | Home Manager 用户配置 | `/etc/nixos/home.nix` |
| `flake.nix` | Nix Flake 配置 | `/etc/nixos/flake.nix` |
| `niri-config.kdl` | Niri 窗口管理器配置 | `~/.config/niri/settings.kdl` |
| `quick-install.sh` | **自动安装脚本** | 运行此脚本快速配置 |

## 🚀 快速开始

### 方式 1: 自动安装 (推荐)

```bash
# 下载并运行自动安装脚本
curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/quick-install.sh | sudo bash

# 或者下载后运行
git clone https://github.com/noctalia-dev/noctalia-shell.git
cd noctalia-shell/examples
sudo bash quick-install.sh
```

### 方式 2: 手动配置

#### 1. 复制配置文件

```bash
# 复制到系统配置目录
sudo cp configuration.nix /etc/nixos/
sudo cp home.nix /etc/nixos/
sudo cp flake.nix /etc/nixos/

# 编辑配置 (根据需要修改)
sudo nano /etc/nixos/configuration.nix
sudo nano /etc/nixos/home.nix
```

#### 2. 构建系统

```bash
# 进入配置目录
cd /etc/nixos

# 构建并激活配置
sudo nixos-rebuild switch --flake .#hostname
# 或
sudo nixos-rebuild switch  # 如果没有使用 flake
```

#### 3. 重启

```bash
sudo reboot
```

## 📋 配置详解

### configuration.nix

NixOS 主配置文件，包含：
- ✅ 基本系统设置 (时区、键盘、语言)
- ✅ Niri 窗口管理器配置
- ✅ Noctalia Shell 服务
- ✅ 显卡驱动支持 (Intel/NVIDIA)
- ✅ 音频系统 (PipeWire)
- ✅ 系统包管理
- ✅ 用户权限配置

### home.nix

Home Manager 用户配置，包含：
- ✅ Noctalia 详细设置
  - Bar 位置和外观
  - 主题和颜色方案
  - 功能开关 (网络、电池、音频等)
- ✅ 用户软件包
- ✅ 程序配置 (Git、Zsh、Neovim、Firefox 等)
- ✅ 自定义配置和别名

### flake.nix

Nix Flake 配置，提供：
- ✅ flake 输入源管理
- ✅ NixOS 配置导出
- ✅ Home Manager 配置
- ✅ 开发环境 (devShells)
- ✅ 包覆盖层

### niri-config.kdl

Niri 配置文件示例，包含：
- ✅ 快捷键绑定
- ✅ 工作区管理
- ✅ 窗口操作
- ✅ 布局设置
- ✅ 主题和颜色
- ✅ 动画效果

## ⚙️ 自定义配置

### 修改用户名和主机名

在 `configuration.nix` 中修改：

```nix
users.users.your-username = {  // 替换 your-username
  isNormalUser = true;
  home = "/home/your-username";
  // ...
};
```

### 启用/禁用功能

在 `home.nix` 中：

```nix
programs.noctalia-shell = {
  settings = {
    // 启用/禁用天气
    weather = {
      enabled = false;  // true 启用，false 禁用
    };

    // 启用/禁用系统监控
    systemMonitor = {
      enabled = true;
    };
  };
};
```

### 添加软件包

在 `configuration.nix` 中：

```nix
environment.systemPackages = with pkgs; [
  # 在这里添加系统包
  firefox
  vlc
  # ...
];
```

在 `home.nix` 中：

```nix
home.packages = with pkgs; [
  # 在这里添加用户包
  neovim
  git
  # ...
];
```

### 配置主题颜色

在 `home.nix` 中修改 `colors` 部分：

```nix
programs.noctalia-shell = {
  colors = {
    mPrimary = "#your-color";  // 主色调
    mSurface = "#your-surface"; // 表面色
    // ...
  };
};
```

### 调整快捷键

在 `niri-config.kdl` 中修改快捷键：

```kdl
// 应用程序启动器
bindsym ["Control", "Mod1", "Super"] {
    exec "wofi --show drun";
}

// 工作区切换
bindsym ["Super", "Key1"] { workspace "1"; }
// ...
```

## 🔧 常见操作

### 更新系统

```bash
# 标准更新
sudo nixos-rebuild switch --upgrade

# 更新 flake
sudo nixos-rebuild switch --flake /etc/nixos#hostname

# 清理旧代
sudo nix-collect-garbage -d
```

### 切换配置

```bash
# 查看当前配置
sudo nixos-option system.stateVersion

# 查看可用代
nix-env --list-generations

# 回滚到前一代
sudo nixos-rebuild switch --rollback
```

### 修改配置

```bash
# 编辑配置
sudo nano /etc/nixos/configuration.nix

# 应用更改
sudo nixos-rebuild switch
```

### 查看服务状态

```bash
# Noctalia 服务
systemctl --user status noctalia-shell.service

# 查看日志
journalctl --user -u noctalia-shell.service -f
```

## 🐛 故障排除

### 构建失败

```bash
# 查看详细错误
journalctl -xeu nixos-rebuild.service

# 检查配置语法
nix-instantiate --parse /etc/nixos/configuration.nix

# 验证 flake
nix flake check /etc/nixos
```

### 服务启动失败

```bash
# 重启服务
systemctl --user restart noctalia-shell.service

# 查看服务日志
journalctl --user -u noctalia-shell.service --no-pager
```

### 依赖缺失

```bash
# 搜索包
nix-env -qaP | grep package-name

# 临时测试包
nix-shell -p package-name
```

### 重置配置

```bash
# 删除用户配置
rm -rf ~/.config/noctalia
rm -rf ~/.config/niri

# 重启服务
systemctl --user restart noctalia-shell.service
```

## 📚 参考资源

### 官方文档
- [NixOS Manual](https://nixos.org/manual/)
- [Niri Documentation](https://yalter.github.io/niri/)
- [Noctalia Docs](https://docs.noctalia.dev)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

### 社区
- [NixOS Discourse](https://discourse.nixos.org/)
- [Niri GitHub](https://github.com/YaLTeR/niri)
- [Noctalia GitHub](https://github.com/noctalia-dev/noctalia-shell)
- [Discord](https://discord.noctalia.dev)

### 教程
- [NixOS Wiki](https://nixos.wiki/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Home Manager Configuration](https://nix-community.github.io/home-manager/options.html)

## 🤝 贡献

欢迎提交问题和改进建议！

1. Fork 项目
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

本示例配置基于 MIT 许可证，与 Noctalia Shell 项目许可证一致。

## ⭐ 支持

如果这些配置对您有帮助，请在 GitHub 上给项目点个星！

---

**祝您使用愉快！** 🎉
