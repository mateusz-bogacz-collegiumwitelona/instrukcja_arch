#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/var/log/yay_install.log"

cleanup() {
    print_msg "Sprzątanie..."
    if [ -d ~/paczki/yay ]; then
        rm -rf ~/paczki/yay
    fi
    exit 1
}

trap cleanup SIGINT SIGTERM

print_msg() {
    echo -e "${BLUE}[*]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1" >> "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
}

if [ "$EUID" -ne 0 ]; then
    print_error "Uruchom skrypt jako root"
    exit 1
fi

if [ -z "$SUDO_USER" ]; then
    print_error "Skrypt musi być uruchomiony przez sudo"
    exit 1
fi

check_dependencies() {
    local dependencies=("git" "base-devel")
    
    for dep in "${dependencies[@]}"; do
        if ! pacman -Qi "$dep" &> /dev/null; then
            print_msg "Instalowanie zależności: $dep"
            if ! pacman -S --needed --noconfirm "$dep"; then
                print_error "Nie udało się zainstalować $dep"
                return 1
            fi
        fi
    done
    return 0
}

install_package_yay() {
    local package=$1
    if ! sudo -u "$SUDO_USER" yay -Qs "$package" &> /dev/null; then
        print_msg "Instalowanie $package..."
        if ! sudo -u "$SUDO_USER" yay -S --noconfirm "$package"; then
            print_error "Nie udało się zainstalować $package"
            return 1
        fi
        print_success "$package zainstalowany pomyślnie"
    else
        print_msg "$package jest już zainstalowany"
    fi
    return 0
}

install_yay() {
    if ! command -v yay &> /dev/null; then
        print_msg "Aktualizacja pakietów systemu..."
        if ! pacman -Syu --noconfirm; then
            print_error "Nie udało się zaktualizować systemu"
            return 1
        fi

        if ! check_dependencies; then
            print_error "Nie udało się zainstalować wymaganych zależności"
            return 1
        fi       
        
        print_msg "Instalowanie yay..."

        sudo -u "$SUDO_USER" mkdir -p ~/paczki
        if [ ! -d ~/paczki ]; then
            print_error "Nie udało się utworzyć katalogu ~/paczki"
            return 1
        fi
        
        cd ~/paczki || {
            print_error "Nie udało się przejść do katalogu ~/paczki"
            return 1
        }
        
        if [ -d yay ]; then
            sudo -u "$SUDO_USER" rm -rf yay
        fi
        
        if ! sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay.git; then
            print_error "Nie udało się sklonować repozytorium yay"
            return 1
        fi
        
        cd yay || {
            print_error "Nie udało się przejść do katalogu yay"
            return 1
        }
        
        if ! sudo -u "$SUDO_USER" makepkg -si --noconfirm; then
            print_error "Nie udało się zbudować i zainstalować yay"
            return 1
        fi
        
        print_success "yay został zainstalowany"
    else
        print_msg "yay jest już zainstalowany"
    fi
    return 0
}

PACKAGES=(
    'google-chrome'
    'intellij-idea-ultimate-edition'
    'phpstorm'
    'pycharm-professional'
    'visual-studio-code-bin'
    'discord'
)

main() {
    if ! install_yay; then
        print_error "Instalacja yay nie powiodła się"
        cleanup
        exit 1
    fi

    print_msg "Instalacja pakietów..."
    for package in "${PACKAGES[@]}"; do
        if ! install_package_yay "$package"; then
            print_error "Nie udało się zainstalować pakietu $package"
            continue
        fi
    done

    print_success "Instalacja zakończona!"
    
    if [ -d ~/paczki/yay ]; then
        sudo -u "$SUDO_USER" rm -rf ~/paczki/yay
    fi
}

main