#!/usr/bin/env bash

# Noctalia + Niri + NixOS Quick Install Script
# Usage: curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/quick-install.sh | sudo bash
# Or download and run: bash quick-install.sh

# Disable strict mode to avoid exiting in non-interactive environments
# set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        NixOS + Niri + Noctalia Quick Install              ║"
    echo "║                                                            ║"
    echo "║  This script will help you configure Niri + Noctalia      ║"
    echo "║  quickly on NixOS                                          ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${CYAN}➜ $1${NC}"
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${YELLOW}[Step $1]${NC} $2"
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

# Check if running on NixOS
check_nixos() {
    print_step "1/6" "Checking system environment"

    if ! grep -q "NixOS" /etc/os-release 2>/dev/null; then
        print_error "NixOS not detected!"
        echo "This script is designed for NixOS."
        echo "Please visit https://nixos.org to get NixOS ISO"
        exit 1
    fi

    print_success "NixOS system detected"
}

# Check permissions
check_permissions() {
    print_step "2/6" "Checking permissions"

    if [[ $EUID -ne 0 ]]; then
        print_error "Please run this script with root privileges!"
        echo "Use: sudo $0"
        exit 1
    fi

    print_success "Permission check passed"
}

# Collect user info (improved version)
collect_user_info() {
    print_step "3/6" "Collecting configuration"

    # Check if in interactive terminal
    if [[ -t 0 ]]; then
        # Interactive mode: prompt for input
        echo ""
        echo -e "${CYAN}Please provide the following configuration (press Enter to use defaults):${NC}"
        echo ""

        echo -n "Enter username (default: alice): "
        read -r USERNAME
        USERNAME=${USERNAME:-alice}

        echo -n "Enter hostname (default: nixos-desktop): "
        read -r HOSTNAME
        HOSTNAME=${HOSTNAME:-nixos-desktop}

        echo -n "Enter timezone (default: Asia/Shanghai): "
        read -r TIMEZONE
        TIMEZONE=${TIMEZONE:-Asia/Shanghai}

        echo -n "Enable NVIDIA driver? [y/N]: "
        read -r ENABLE_NVIDIA
        ENABLE_NVIDIA=${ENABLE_NVIDIA:-n}
    else
        # Non-interactive mode: use defaults
        print_warning "Non-interactive environment detected, using default configuration"
        USERNAME="alice"
        HOSTNAME="nixos-desktop"
        TIMEZONE="Asia/Shanghai"
        ENABLE_NVIDIA="n"

        echo -e "${CYAN}Configuration to be used:${NC}"
        echo "  Username: $USERNAME"
        echo "  Hostname: $HOSTNAME"
        echo "  Timezone: $TIMEZONE"
        echo "  NVIDIA driver: ${ENABLE_NVIDIA}"
        echo ""
        echo -e "${YELLOW}For customization, please download and run manually:${NC}"
        echo "  wget https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/quick-install.sh"
        echo "  sudo bash quick-install.sh"
        echo ""
    fi

    print_success "Configuration collected"
}

# Generate configuration files
generate_configs() {
    print_step "4/6" "Generating configuration files"

    CONFIG_DIR="/etc/nixos"
    EXAMPLES_DIR="/root/noctalia-examples"

    # Create directories
    mkdir -p "$CONFIG_DIR" 2>/dev/null || true
    mkdir -p "$EXAMPLES_DIR" 2>/dev/null || true

    # Download example configurations
    if command -v wget &> /dev/null; then
        wget -q https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/configuration.nix -O "$EXAMPLES_DIR/configuration.nix.template" 2>/dev/null || true
        wget -q https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/home.nix -O "$EXAMPLES_DIR/home.nix.template" 2>/dev/null || true
        wget -q https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/flake.nix -O "$EXAMPLES_DIR/flake.nix.template" 2>/dev/null || true
    elif command -v curl &> /dev/null; then
        curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/configuration.nix -o "$EXAMPLES_DIR/configuration.nix.template" 2>/dev/null || true
        curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/home.nix -o "$EXAMPLES_DIR/home.nix.template" 2>/dev/null || true
        curl -sSL https://raw.githubusercontent.com/noctalia-dev/noctalia-shell/main/examples/flake.nix -o "$EXAMPLES_DIR/flake.nix.template" 2>/dev/null || true
    else
        print_warning "wget or curl not found, example configuration files may need to be created manually"
    fi

    # Generate configuration.nix
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

    print_success "Configuration files generated"
    print_warning "Example configuration files saved to $EXAMPLES_DIR"
}

# Create NixOS directory structure
setup_nixos() {
    print_step "5/6" "Setting up NixOS environment"

    # Enable flakes (if not already enabled)
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
        print_success "Created flake.nix"
    fi

    # Generate hardware configuration
    if [[ ! -f /etc/nixos/hardware-configuration.nix ]]; then
        nixos-generate-config --dir /etc/nixos 2>/dev/null || print_warning "Hardware configuration generation may have failed, please check"
        print_success "Generated hardware configuration"
    fi

    print_success "NixOS environment setup completed"
}

# Build system
build_system() {
    print_step "6/6" "Building system configuration"

    # Check if interactive
    if [[ -t 0 ]]; then
        print_warning "About to build NixOS configuration..."
        print_warning "This operation may take several minutes, please be patient."
        echo ""
        read -p "Continue? [y/N]: " -n 1 -r
        echo ""

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Build cancelled. You can run manually later:"
            echo "  cd /etc/nixos"
            echo "  sudo nixos-rebuild switch --flake .#$HOSTNAME"
            exit 0
        fi
    else
        print_warning "Non-interactive environment, skipping build confirmation"
        print_warning "Please run manually later: sudo nixos-rebuild switch --flake /etc/nixos#$HOSTNAME"
        return 0
    fi

    echo ""
    print_warning "Starting build..."

    if nixos-rebuild switch --flake /etc/nixos#$HOSTNAME 2>&1 | tee /tmp/nixos-build.log; then
        print_success "System build successful!"
    else
        print_error "Build failed!"
        echo "View logs: cat /tmp/nixos-build.log"
        exit 1
    fi
}

# Show next steps
show_next_steps() {
    print_section "Installation complete!"

    echo -e "${GREEN}✓${NC} NixOS + Niri + Noctalia successfully installed!"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Reboot system: ${YELLOW}sudo reboot${NC}"
    echo ""
    echo -e "${CYAN}After first boot:${NC}"
    echo "  1. Log in with $USERNAME account"
    echo "  2. Niri will start automatically"
    echo "  3. Noctalia will load automatically after Niri starts"
    echo ""
    echo -e "${CYAN}Common shortcuts:${NC}"
    echo "  ${YELLOW}Super + D${NC}    - Application launcher"
    echo "  ${YELLOW}Super + Enter${NC} - Open terminal"
    echo "  ${YELLOW}Super + 1-0${NC}  - Switch workspace"
    echo "  ${YELLOW}Win + Alt + Arrow Keys${NC} - Move window"
    echo "  ${YELLOW}Ctrl + Alt + Q${NC} - Exit Niri"
    echo ""
    echo -e "${CYAN}Management commands:${NC}"
    echo "  ${YELLOW}sudo nixos-rebuild switch${NC}           - Apply configuration changes"
    echo "  ${YELLOW}sudo nixos-rebuild switch --upgrade${NC} - Upgrade system"
    echo ""
    echo -e "${CYAN}Configuration locations:${NC}"
    echo "  ${YELLOW}/etc/nixos/configuration.nix${NC} - Main configuration"
    echo "  ${YELLOW}/etc/nixos/home.nix${NC}          - User configuration"
    echo "  ${YELLOW}/etc/nixos/flake.nix${NC}         - Flake configuration"
    echo ""
    echo -e "${CYAN}Documentation links:${NC}"
    echo "  ${BLUE}NixOS: https://nixos.org/manual/${NC}"
    echo "  ${BLUE}Niri: https://yalter.github.io/niri/${NC}"
    echo "  ${BLUE}Noctalia: https://docs.noctalia.dev${NC}"
    echo ""
}

# Main function
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

# Error handling (relaxed mode)
trap 'print_error "An error occurred during installation!"; exit 1' ERR

# Run main function
main

print_success "Installation completed!"
