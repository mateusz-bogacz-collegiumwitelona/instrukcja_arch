#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m' 
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/var/log/nano_optymalization.log"

cleanup() {
   print_msg "Czyszczenie..."
   if [ -f /etc/.nanorc.new ]; then
      rm /etc/.nanorc.new
   fi

   if [ -f /etc/.nanorc.old ]; then
      mv /etc/.nanorc.old /etc/.nanorc
   fi

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

if ! command -v nano &> /dev/null; then
   print_msg "nano nie jest zainstalowane. Instalowanie..."
   if ! pacman -S nano --noconfirm &> /dev/null; then
      print_error "Błąd instalacji nano"
      exit 1
   fi
fi

print_msg "Konfigurowanie nano..."

print_msg "Aktualizowanie repo..."
if ! pacman -Syu --noconfirm; then
   print_error "Błąd aktualizacji repo"
   exit 1
fi 

print_msg "Instalowanie nano-syntax-highlighting..."
if ! pacman -S nano-syntax-highlighting --noconfirm; then
   print_error "Błąd instalacji nano-syntax-highlighting"
   print_msg "Kontynuowanie bez kolorowania składni..."
fi

if [ -f /etc/.nanorc ]; then
   print_msg "Tworzenie kopii zapasowej pliku /etc/.nanorc..."
   if ! cp /etc/.nanorc /etc/.nanorc.old; then
      print_error "Błąd tworzenia kopii zapasowej pliku /etc/.nanorc"
      exit 1
   fi
fi

print_msg "Tworzenie nowej konfiguracji nano..."
cat > ~/.nanorc.new << 'EOF'
# Podstawowe ustawienia
set autoindent
set tabsize 4
set tabstospaces
set linenumbers
set constantshow
set softwrap

# Kolorowanie składni
include "/usr/share/nano/*.nanorc"

# Dodatkowe ustawienia
set brackets ""')>]}"
set matchbrackets "(<[{)>]}"
set showcursor
set smarthome
set smooth
set suspend
EOF

if [ ! -f ~/.nanorc.new ]; then
   print_error "Błąd tworzenia nowej konfiguracji nano"
   cleanup
fi

if ! mv ~/.nanorc.new /etc/.nanorc; then
   print_error "Błąd zastępowania pliku /etc/.nanorc"
   cleanup
fi

if ! chmod 644 /etc/.nanorc; then
   print_error "Nie udało się nadać odpowiednich uprawnień do pliku /etc/.nanorc"
   cleanup
fi

if ! nano -V &> /dev/null; then
   print_error "Błąd uruchomienia nano"
   cleanup
fi

print_success "Konfiguracja nano zakończona pomyślnie"
print_msg "Uruchom nano, aby sprawdzić efekty"
print_msg "Kopia zapasowa poprzedniej konfiguracji znajduje się w ~/.nanorc.old"