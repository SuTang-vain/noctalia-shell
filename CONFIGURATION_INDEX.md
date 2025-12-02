# 📚 NixOS + Niri + Noctalia 配置文档索引

## 🎯 快速导航

### 📖 主要文档

| 文档 | 描述 | 文件 |
|------|------|------|
| **完整配置指南** | 从零开始的详细安装步骤 | [NIXOS_NIRI_NOCTALIA_SETUP.md](../NIXOS_NIRI_NOCTALIA_SETUP.md) |
| **配置示例说明** | 示例文件使用说明 | [examples/README.md](examples/README.md) |
| **主项目文档** | Noctalia Shell 项目信息 | [README.md](../README.md) |

### ⚡ 快速安装

```bash
# 自动安装 (推荐)
curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/quick-install.sh | sudo bash

# 手动克隆
git clone https://github.com/noctalia-dev/noctalia-shell.git
cd noctalia-shell/examples
sudo bash quick-install.sh
```

---

## 📁 文件结构

```
noctalia-shell/
├── 📘 NIXOS_NIRI_NOCTALIA_SETUP.md          # 完整安装指南 (60页详细文档)
│
├── examples/                                 # 配置示例目录
│   ├── 🚀 quick-install.sh                   # 自动安装脚本 (交互式)
│   ├── 📝 README.md                         # 使用说明
│   ├── ⚙️ configuration.nix                  # NixOS 主配置
│   ├── 🏠 home.nix                          # Home Manager 用户配置
│   ├── 🔗 flake.nix                         # Nix Flake 配置
│   └── 🎨 niri-config.kdl                    # Niri 窗口管理器配置
│
└── CONFIGURATION_INDEX.md                    # 本文档
```

---

## 🚀 三种配置方式

### 方式 1: 自动安装 (推荐新手)

**优点**: 一键配置，交互式向导，详细提示
**使用场景**: 首次安装，希望快速完成配置

```bash
curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/quick-install.sh | sudo bash
```

**特性**:
- ✅ 自动检测系统环境
- ✅ 交互式收集配置信息
- ✅ 自动生成配置文件
- ✅ 自动构建系统
- ✅ 彩色输出和进度提示

---

### 方式 2: 使用 flake (推荐开发者)

**优点**: 现代化、可重现、模块化
**使用场景**: 有经验的 NixOS 用户，使用 Home Manager

```bash
# 1. 复制 flake 配置
sudo cp examples/flake.nix /etc/nixos/flake.nix

# 2. 编辑配置 (可选)
sudo nano /etc/nixos/flake.nix

# 3. 构建
cd /etc/nixos
sudo nixos-rebuild switch --flake .#hostname
```

**特性**:
- ✅ Flake 输入管理
- ✅ 包覆盖层支持
- ✅ 开发环境集成
- ✅ 版本锁定

---

### 方式 3: 手动配置 (推荐专家)

**优点**: 完全控制，可深度定制
**使用场景**: 需要精细控制每个配置项

```bash
# 1. 复制所有配置文件
sudo cp examples/configuration.nix /etc/nixos/configuration.nix
sudo cp examples/home.nix /etc/nixos/home.nix
sudo cp examples/niri-config.kdl ~/.config/niri/settings.kdl

# 2. 编辑配置
sudo nano /etc/nixos/configuration.nix
sudo nano /etc/nixos/home.nix

# 3. 构建系统
sudo nixos-rebuild switch
```

**特性**:
- ✅ 完全自定义
- ✅ 透明配置
- ✅ 无隐藏逻辑
- ✅ 易于调试

---

## 📋 详细功能对比

| 功能 | 自动安装 | Flake | 手动配置 |
|------|----------|-------|----------|
| **难度** | ⭐ | ⭐⭐ | ⭐⭐⭐ |
| **时间** | 5分钟 | 15分钟 | 30分钟 |
| **可定制性** | 中 | 高 | 极高 |
| **模块化** | 低 | 高 | 中 |
| **版本锁定** | 自动 | 自动 | 手动 |
| **错误处理** | 智能 | 基础 | 手动 |
| **配置迁移** | 简单 | 简单 | 复杂 |

---

## 🎨 预配置特性

### 🖥️ 桌面环境
- ✅ Niri 窗口管理器
  - 自动检测 compositor
  - 工作区管理
  - 窗口浮动
  - 快捷键绑定
- ✅ Noctalia Shell
  - 任务栏 (Top/Bottom/Left/Right)
  - 系统托盘
  - 应用启动器
  - 通知中心

### 🎯 核心功能
- ✅ 网络指示器
- ✅ 电池状态
- ✅ 音量控制
- ✅ 亮度控制
- ✅ 系统监控 (CPU/RAM)
- ✅ 时钟显示
- ✅ 天气显示 (可选)
- ✅ 自动深色模式
- ✅ 锁屏功能
- ✅ 壁纸管理

### 🎨 主题
- ✅ 默认紫色主题 (#A8AEFF)
- ✅ 深色模式
- ✅ 毛玻璃效果
- ✅ 动态颜色 (基于壁纸)
- ✅ 自定义颜色方案

### ⌨️ 快捷键
| 快捷键 | 功能 |
|--------|------|
| `Super + D` | 应用启动器 |
| `Super + Enter` | 终端 |
| `Super + 1-0` | 工作区切换 |
| `Win + Alt + 方向键` | 移动窗口 |
| `Ctrl + Alt + Q` | 退出 Niri |

---

## 🔧 硬件支持

### 显卡驱动
- ✅ Intel 集成显卡 (默认启用)
- ✅ NVIDIA 独立显卡 (可选)
- ✅ AMD 显卡 (使用开源驱动)

### 音频系统
- ✅ PipeWire (现代音频系统)
- ✅ ALSA 兼容
- ✅ Jack 支持

### 输入设备
- ✅ 触摸板 (自然滚动、点击)
- ✅ 鼠标 (指针速度调节)
- ✅ 键盘布局切换

---

## 📦 预装软件

### 系统工具
- **终端**: Alacritty
- **Shell**: Zsh + Starship
- **编辑器**: Neovim
- **版本控制**: Git

### 网络
- **浏览器**: Firefox
- **下载**: curl, wget

### 媒体
- **视频**: VLC, MPV
- **音乐**: Spotify

### 开发
- **运行时**: Node.js, Python3, Go, Rust
- **包管理**: npm, pip, cargo

### 系统
- **系统监控**: btop, htop
- **文件查找**: fzf, ripgrep, fd

---

## 🎯 推荐配置路径

### 👶 新手推荐

**路径**: 自动安装 → 体验 → 逐步学习

```bash
# 1. 快速安装
curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/quick-install.sh | sudo bash

# 2. 重启后体验

# 3. 逐步自定义
sudo nano /etc/nixos/configuration.nix
```

---

### 💻 开发者推荐

**路径**: Flake 配置 → 模块化 → 开发环境

```bash
# 1. 使用 flake
sudo cp examples/flake.nix /etc/nixos/
sudo nixos-rebuild switch --flake /etc/nixos#hostname

# 2. 进入开发环境
nix develop github:noctalia-dev/noctalia-shell

# 3. 自定义模块
```

---

### 🎨 极客推荐

**路径**: 手动配置 → 深度定制 → 源码构建

```bash
# 1. 复制所有配置
sudo cp examples/*.nix /etc/nixos/

# 2. 从源码构建
git clone https://github.com/noctalia-dev/noctalia-shell.git
cd noctalia-shell
nix build

# 3. 深度定制
```

---

## 🆘 获取帮助

### 📚 文档资源
- [NixOS Manual](https://nixos.org/manual/)
- [Niri Documentation](https://yalter.github.io/niri/)
- [Noctalia Docs](https://docs.noctalia.dev)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)

### 💬 社区支持
- **Discord**: [Noctalia Community](https://discord.noctalia.dev)
- **GitHub Issues**: [报告问题](https://github.com/noctalia-dev/noctalia-shell/issues)
- **NixOS Discourse**: [讨论区](https://discourse.nixos.org/)

### 🔍 搜索问题
```bash
# 搜索 NixOS 选项
nixos-option services.noctalia-shell.enable

# 验证 flake
nix flake check

# 查看日志
journalctl --user -u noctalia-shell.service -f
```

---

## 📈 配置复杂度阶梯

```
Level 1: 自动安装 → 5分钟 → 立即使用
Level 2: Flake 配置 → 15分钟 → 模块化
Level 3: 手动配置 → 30分钟 → 完全控制
Level 4: 源码构建 → 1小时 → 开发模式
Level 5: 定制开发 → 自定义 → 贡献代码
```

---

## ✅ 验证清单

安装完成后，请验证以下功能：

- [ ] 系统正常启动
- [ ] Niri 窗口管理器加载
- [ ] Noctalia 任务栏显示
- [ ] 应用启动器工作 (Super+D)
- [ ] 终端打开 (Super+Enter)
- [ ] 工作区切换 (Super+1-0)
- [ ] 音量控制可用
- [ ] 电池状态显示
- [ ] 网络指示器工作
- [ ] 颜色主题应用
- [ ] 无错误日志

---

## 🎉 开始使用

**选择一个配置方式，开始您的 NixOS + Niri + Noctalia 之旅！**

### 快速开始 (推荐)
```bash
curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/quick-install.sh | sudo bash
```

### 完整指南
```bash
cat NIXOS_NIRI_NOCTALIA_SETUP.md
```

---

## 📝 更新日志

- **2024-12-02**: 初始版本发布
  - 完整配置指南 (18KB)
  - 自动安装脚本
  - 5个示例配置文件
  - 详细故障排除指南

---

## ⭐ 致谢

感谢以下项目：
- [NixOS](https://nixos.org/) - 可重现操作系统
- [Niri](https://github.com/YaLTeR/niri) - 现代 Wayland 窗口管理器
- [Noctalia](https://github.com/noctalia-dev/noctalia-shell) - 美丽桌面环境
- [Quickshell](https://github.com/CuarzoSoftware/Quickshell) - 动态 Shell 框架
- [Home Manager](https://github.com/nix-community/home-manager) - 用户环境管理

---

**享受您的 Linux 桌面体验！** 🎨✨

---

> 📌 **注意**: 本文档随项目持续更新。最新版本请访问 GitHub 仓库。
