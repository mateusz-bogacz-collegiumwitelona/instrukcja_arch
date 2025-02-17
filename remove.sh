#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/var/log/remove.log"

print_msg() {
    echo -e "${BLUE}[*]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

if [[ $EUID -ne 0 ]]; then
    print_error "Skrypt wymaga uprawnień roota"
    exit 1
fi

PACKAGES=(
    'epiphany'
    'gnome-contacts'
    'gnome-maps'
    'totem'
    'malcontent'
    'gnome-tour'
    'gnome-user-docs'
    'gnome-weather'
)

print_msg "Usuwanie pakietów..."
for package in "${PACKAGES[@]}"; do
    if pacman -Qs "$package" &> /dev/null; then
        print_msg "Usuwanie $package..."
        if pacman -Rns --noconfirm "$package"; then
            print_success "$package usunięty"
        else
            print_error "Błąd podczas usuwania $package"
        fi
    else
        print_msg "Pakiet $package nie jest zainstalowany"
    fi
done

print_success "Usuwanie niepotrzebnych programów zakończone"