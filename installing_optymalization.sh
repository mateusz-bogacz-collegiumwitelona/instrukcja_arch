#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/var/log/installing_optymalization.log"

cleanup() {
    print_msg "Czyszczenie..."
    if [ -f /etc/pacman.conf.new ]; then
        rm /etc/pacman.conf.new
    fi

    if [ -f /etc/pacman.conf.old ]; then
        mv /etc/pacman.conf.old /etc/pacman.conf
    fi 

    print_msg "Czyszczenie zakończone"
    exit 1
}

trap cleanup SIGNINT SIGTERM

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

if [ "$#" -ne 1 ]; then
    print_error "Użycie: $0 ścieżka/do/my_pacman"
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    print_error "Plik $file nie istnieje"
    exit 1
fi

if [ ! -r "$file" ]; then
    print_error "Brak uprawnień do odczytu pliku $file"
    exit 1
fi

if ! grep -q "\[options\]" "$file"; then
    print_error "Plike $file nie wygląda na prawidłowy plik konfiguracyjny pacman"
    exit 1
fi

print_msg "Konfigurowanie pacman.conf..."
if [ -f /etc/pacman.conf ]; then
    cp /etc/pacman.conf /etc/pacman.conf.old
    if [ $? -ne 0 ]; then
        print_error "Nie udało się styworzyć kopii zapasowej pliku /etc/pacman.conf"
        exit 1
    fi
    print_success "Utworzono kopię zapasową orginalej wersji pliku /etc/pacman.conf"
fi

cp "$file" /etc/pacman.conf.new
if [ $? -ne 0 ]; then
    print_error "Nie udało się skopiować nowej konfiguracji"
    cleanup
fi

if ! pacman-conf --config /etc/pacman.conf.new &>/dev/null; then
    print_error "Nowa konfiguracja nie jest poprawna"
    cleanup
fi

mv /etc/pacman.conf.new /etc/pacman.conf
if [ $? -ne 0 ]; then
    print_error "Nie udało się zastąpić pliku /etc/pacman.conf"
    cleanup
fi

print_msg "Konfigurowanie yay..."
if ! command -y yay &>/dev/null; then
    print_error "Yay nie jest zainstalowany. Instalacja może nie być kompletna"
fi

mkdir -p !/.congif/yay
if [ $? -ne 0 ]; then
    print_error "Nie udało się utworzyć katalogu ~/.config/yay"
    exit 1
fi

cat > ~/.config/yay/config.json <<EOF
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
if [ $? -ne 0 ]; then
    print_error "Nie udało się utworzyć pliku ~/.config/yay/config.json"
    exit 1
fi

print_success "Konfiguracja zakończona pomyślnie"
print_msg "Zresetuj terminal aby zastosować zmiany"
print_msg "Kopia zapasowa oryginalnej konfiguracji znajduje się w /etc/pacman.conf.old"
