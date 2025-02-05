#!/bin/bash

# Kolory do lepszej czytelności
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funkcje do wyświetlania komunikatów
print_msg() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

# Sprawdzenie uprawnień roota
if [ "$EUID" -ne 0 ]; then
    print_error "Uruchom skrypt jako root"
    exit 1
fi

# Sprawdzenie i instalacja yay
if ! command -v yay &> /dev/null; then
    print_msg "Aktualizacja pakietów systemu"
    pacman -Syu --noconfirm
    
    print_msg "Instalowanie yay i tworzenie folderu do przechowywania plików"
    
    # Tworzenie katalogu na pakiety
    sudo -u $SUDO_USER mkdir -p ~/paczki
    cd ~/paczki
    
    # Klonowanie i instalacja yay
    sudo -u $SUDO_USER git clone https://aur.archlinux.org/yay.git
    cd yay
    sudo -u $SUDO_USER makepkg -si --noconfirm
    
    print_success "yay został zainstalowany"
else
    print_msg "yay jest już zainstalowany"
fi

# Lista pakietów do instalacji
PACKAGES=(
    'auto-cpufreq'
    'google-chrome'
    'intellij-idea-ultimate-edition'
    'phpstorm'
    'pycharm-professional'
    'visual-studio-code-bin'
    'discord'
)

# Instalacja pakietów
print_msg "Instalacja pakietów..."
for package in "${PACKAGES[@]}"; do
    if ! yay -Qs "$package" &> /dev/null; then
        print_msg "Instalowanie $package..."
        sudo -u $SUDO_USER yay -S --noconfirm "$package" || print_error "Nie udało się zainstalować $package"
    else
        print_msg "$package jest już zainstalowany"
    fi
done

print_success "Instalacja zakończona!"