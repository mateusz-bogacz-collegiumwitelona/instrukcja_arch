#!/bin/bash

# Kolory do wyświetlania
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funkcje pomocnicze
print_msg() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Skrypt wymaga uprawnień roota"
        exit 1
    fi
}

# Sprawdź uprawnienia
check_root

# Konfiguracja pacman.conf
print_msg "Konfigurowanie pacman.conf..."
sed -i '/^#Color/c\Color' /etc/pacman.conf
sed -i '/^#ParallelDownloads/c\ParallelDownloads = 5' /etc/pacman.conf
echo "ILoveCandy" | tee -a /etc/pacman.conf
print_success "Skonfigurowano pacman.conf"

# Tworzenie katalogu konfiguracyjnego yay
print_msg "Konfigurowanie yay..."
mkdir -p ~/.config/yay

# Konfiguracja yay
cat > ~/.config/yay/config.json << 'EOF'
{
    "aururl": "https://aur.archlinux.org",
    "builddir": "$HOME/.cache/yay",
    "editor": "",
    "editorflags": "",
    "makepkgbin": "makepkg",
    "pacmanbin": "pacman",
    "pacmanconf": "/etc/pacman.conf",
    "redownload": "no",
    "sudoloop": true,
    "removemake": true,
    "cleanafter": true
}
EOF

print_success "Konfiguracja zakończona pomyślnie"
print_msg "Zrestartuj terminal aby zastosować zmiany"