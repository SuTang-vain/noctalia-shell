# Home Manager 配置
# 文件路径: /etc/nixos/home.nix

{ config, pkgs, ... }:

{
  # 导入 Home Manager 和 Noctalia 模块
  imports = [
    # 从 GitHub 导入 Noctalia Home 模块
    (import (builtins.fetchTarball {
      url = "https://github.com/noctalia-dev/noctalia-shell/archive/main.tar.gz";
    })).homeModules.default
  ];

  # ===== Noctalia Shell 配置 =====

  programs.noctalia-shell = {
    enable = true;

    # 启用 systemd 服务集成
    systemd.enable = true;

    # 使用 flake 中的包
    package = (import (builtins.fetchTarball {
      url = "https://github.com/noctalia-dev/noctalia-shell/archive/main.tar.gz";
    })).packages.x86_64-linux.default;

    # ===== 基础设置 =====

    settings = {
      # ===== 栏 (Bar) 配置 =====
      bar = {
        position = "bottom";      // top | bottom | left | right
        floating = false;
        backgroundOpacity = 0.95;
        height = 40;
        outerCorners = true;
      };

      # ===== 通用设置 =====
      general = {
        animationSpeed = 1.5;
        radiusRatio = 1.2;
        blurEnabled = true;
        blurRadius = 20;
      };

      # ===== 颜色方案 =====
      colorSchemes = {
        darkMode = true;
        useWallpaperColors = true;
        autoDarkMode = true;
        autoDarkModeTime = {
          enabled = true;
          lightStart = "07:00";
          lightEnd = "19:00";
        };
      };

      # ===== 应用启动器 =====
      appLauncher = {
        useApp2Unit = false;
        fuzzySearch = true;
        searchInstalledOnly = false;
      };

      # ===== 系统托盘 =====
      systemTray = {
        enabled = true;
        position = "right";
      };

      # ===== 工作区 =====
      workspaces = {
        showEmpty = true;
        iconMode = "number";  // number | name | icon
        showOnAllDisplays = false;
      };

      # ===== 网络 =====
      network = {
        showSignal = true;
        showSpeed = false;
        showWifiInfo = true;
      };

      # ===== 电池 =====
      battery = {
        showPercentage = true;
        showTime = true;
        showHealth = false;
        lowThreshold = 20;
        criticalThreshold = 10;
      };

      # ===== 音量 =====
      audio = {
        showVolume = true;
        showSink = true;
        mixerCommand = "pavucontrol";
      };

      # ===== 亮度 =====
      brightness = {
        showBrightness = true;
        step = 5;
      };

      # ===== 时钟 =====
      clock = {
        show24Hours = false;
        showSeconds = false;
        showDate = true;
        timezone = "local";  // local | utc
      };

      # ===== 系统监控 =====
      systemMonitor = {
        enabled = true;
        showCPU = true;
        showRAM = true;
        showDisk = false;
        showTemperature = false;
        updateInterval = 1000;  // ms
      };

      # ===== 天气 (需要配置位置) =====
      weather = {
        enabled = false;  // 设为 true 并配置位置
        updateInterval = 600000;  // 10 分钟
        showForecast = true;
        unit = "celsius";  // celsius | fahrenheit
      };

      # ===== 锁屏 =====
      lockscreen = {
        enabled = true;
        autoLockAfter = 300;  // 5 分钟无操作
        showClock = true;
        showWeather = false;
      };

      # ===== 通知 =====
      notifications = {
        enabled = true;
        position = "top-right";
        maxNotifications = 5;
        timeout = 5000;
      };

      # ===== 截图 =====
      screenshot = {
        enabled = true;
        savePath = "~/Pictures/Screenshots";
        copyToClipboard = true;
      };

      # ===== 壁纸 =====
      wallpaper = {
        enabled = true;
        path = "~/Pictures/Wallpapers";  // 修改为你的壁纸路径
        randomize = true;
        interval = 3600;  // 1 小时切换
        slideshowEnabled = false;
        overviewEnabled = true;
      };
    };

    # ===== 自定义颜色方案 =====

    colors = {
      // 错误颜色
      mError = "#ff6b6b";
      mOnError = "#ffffff";

      // 主要颜色
      mPrimary = "#A8AEFF";
      mOnPrimary = "#ffffff";
      mOnPrimaryContainer = "#1a1a1a";
      mPrimaryContainer = "#d8d9ff";

      // 次要颜色
      mSecondary = "#a7a7a7";
      mOnSecondary = "#111111";

      // 表面颜色
      mSurface = "#0C0D11";
      mOnSurface = "#e0e0e0";
      mSurfaceVariant = "#191919";
      mOnSurfaceVariant = "#b0b0b0";

      // 边框和阴影
      mOutline = "#3c3c3c";
      mShadow = "#000000";

      // 第三色
      mTertiary = "#d4c4fb";
      mOnTertiary = "#000000";
    };

    # ===== App2Unit 包 (可选) =====
    app2unit.package = pkgs.app2unit;
  };

  # ===== 用户包 =====

  home.packages = with pkgs; [
    # 基础工具
    git
    gitui
    neovim
    helix
    htop
    btop
    curl
    wget
    ripgrep
    fd
    fzf
    exa
    bat

    # Shell
    zsh
    starship
    oh-my-zsh
    zsh-autosuggestions
    zsh-syntax-highlighting

    # 终端工具
    alacritty
    kitty
    tmux
    tmuxp

    # 浏览器
    firefox
    qutebrowser

    # 媒体
    vlc
    mpv
    spotify
    audacity
    OBSStudio

    # 文档阅读
    zotero
    okular
    evince

    # 开发工具
    nodejs
    nodePackages.vite
    nodePackages.yarn
    python3
    python3Packages.pip
    go
    rustup
    cargo
    cargo-watch
    bun
    deno

    # 版本控制
    git
    gh
    glab
    lazygit

    # 数据库工具
    postgresql
    sqlitebrowser
    redisinsight

    # 图像和设计
    gimp
    inkscape
    blender
    krita

    # 通讯
    discord
    telegram-desktop

    # 系统工具
    systemd
    qalculate
    keepassxc
    bitwarden
  ];

  # ===== 程序配置 =====

  # Git 配置
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      credential.helper = "store";
      core.autocrlf = "input";
    };

    includes = [
      {
        condition = "gitdir:~/work/"
        contents = {
          user.name = "Work Name";
          user.email = "work@company.com";
        };
      }
    ];
  };

  # Zsh 配置
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "exa -la";
      la = "exa -a";
      l = "exa -l";
      gs = "git status";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      update = "sudo nixos-rebuild switch";
      upgrade = "sudo nixos-rebuild switch --upgrade";
      clean = "nix-store --gc";
    };

    initExtra = ''
      # Starship 配置
      eval "$(starship init zsh)"

      # 自动建议
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

      # 语法高亮
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

      # 路径提示
      export PATH="$HOME/.local/bin:$PATH"

      # 代理设置 (根据需要取消注释)
      # export http_proxy="http://127.0.0.1:7890"
      # export https_proxy="http://127.0.0.1:7890"
    '';
  };

  # Starship 提示符
  programs.starship = {
    enable = true;
    settings = {
      format = """$directory$git_branch$git_status$hostname$username$shlvl$kubernetes$line_break$python$nodejs$rust$go$nix_shell$cmd_duration$character""";

      right_format = "$battery$time";

      add_newline = false;

      battery = {
        full_symbol = "⚡ ";
        charging_symbol = "🔌 ";
        discharging_symbol = "🔋 ";
        unknown_symbol = "? ";
        empty_symbol = "⛔ ";
      };

      time = {
        disabled = false;
        format = "🕒 [\[$time\]]($style)";
      };

      directory = {
        style = "cyan bold";
        format = "📁 [$path]($style)";
        truncation_length = 3;
        truncate_to_repo = true;
      };
    };
  };

  # Neovim 配置
  programs.neovim = {
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;

    plugins = with pkgs.vimPlugins; [
      # 包管理器
      vim-plug

      # 主题
      tokyonight-nvim
      catppuccin-nvim

      # LSP
      nvim-lspconfig
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp-nvim-lsp

      # 语法高亮
      nvim-treesitter
      nvim-treesitter-textobjects

      # 文件探索
      nvim-tree-lua
      telescope-nvim

      # 状态栏
      lualine-nvim

      # 其他
      gitsigns-nvim
      undotree
      vim-fugitive
    ];
  };

  # Firefox 配置
  programs.firefox = {
    enable = true;
    policies = {
      DisplayBookmarksToolbar = "always";
      DefaultCookieSettings = {
        cookieBehavior = 1;  // Block third-party cookies
      };
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
      };
    };
  };

  # Alacritty 终端配置
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 14;
        normal = { family = "JetBrains Mono"; style = "Regular"; };
        bold = { family = "JetBrains Mono"; style = "Bold"; };
        italic = { family = "JetBrains Mono"; style = "Italic"; };
      };

      colors = {
        primary = {
          background = "#0C0D11";
          foreground = "#e0e0e0";
        };

        cursor = {
          cursor = "#A8AEFF";
          text = "#0C0D11";
        };
      };

      key_bindings = [
        { key = "L", mods = "Control|Shift"; action = "Character"; }
        { key = "L", mods = "Control"; action = "Paste"; }
      ];
    };
  };

  # ===== 文件配置 =====

  # 创建目录
  xdg.configFile."niri/settings.kdl".text = ''
    focus new-window "last"
    move modify ["Control" "Alt"]
    resize modify ["Control" "Shift" "Alt"]
    layouts { spacing 10; workspace-padding 20; }
    colors { bg "#0C0D11"; bg-alt "#111111"; border "#A8AEFF"; text "#ffffff"; text-dim "#888888"; }
    quit confirm
  '';

  # Tmux 配置
  xdg.configFile."tmux/tmux.conf".text = ''
    set -g mouse on
    set -g history-limit 10000
    set -g escape-time 0
    set -g default-terminal "screen-256color"

    # 键位前缀
    set -g prefix C-a
    unbind C-b
    bind C-a send-prefix

    # 窗口和面板
    bind c new-window -c "#{pane_current_path}"
    bind % split-window -h -c "#{pane_current_path}"
    bind '"' split-window -v -c "#{pane_current_path}"

    # 面板导航
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # 状态栏
    set -g status-interval 1
    set -g status-style "bg=#0C0D11 fg=#e0e0e0"
    set -g status-left-length 30
    set -g status-right-length 80
    set -g status-left "#{session_name}"
    set -g status-right "#{battery_icon} #{battery_percentage} | %H:%M:%S | %Y-%m-%d"
  '';

  # ===== Home Manager 配置 =====

  home.username = "alice";
  home.homeDirectory = "/home/alice";

  home.stateVersion = "24.11";
}
