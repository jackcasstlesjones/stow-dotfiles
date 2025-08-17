#!/bin/bash

# Dotfiles installation script using GNU stow
# Run this script from the dotfiles directory

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the dotfiles directory
if [[ ! -d "$DOTFILES_DIR" ]]; then
    print_error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# Packages to install
PACKAGES=("kitty" "waybar" "nvim" "hypr")

# Function to backup existing configs
backup_existing() {
    local package="$1"
    local config_path="$HOME/.config/$package"
    
    if [[ -d "$config_path" && ! -L "$config_path" ]]; then
        print_warning "Existing $package config found. Backing up to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        mv "$config_path" "$BACKUP_DIR/"
    fi
}

# Function to install package with stow
install_package() {
    local package="$1"
    
    if [[ ! -d "$package" ]]; then
        print_warning "Package $package not found, skipping"
        return
    fi
    
    print_status "Installing $package configuration"
    backup_existing "$package"
    
    if stow -v "$package"; then
        print_status "$package configuration installed successfully"
    else
        print_error "Failed to install $package configuration"
        return 1
    fi
}

# Main installation
print_status "Starting dotfiles installation"

# Install each package
for package in "${PACKAGES[@]}"; do
    install_package "$package"
done

print_status "Dotfiles installation complete!"
print_status "You can now run 'stow <package>' to install individual configs"
print_status "Or 'stow -D <package>' to remove them"

if [[ -d "$BACKUP_DIR" ]]; then
    print_status "Original configs backed up to: $BACKUP_DIR"
fi