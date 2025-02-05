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

# Główna funkcja
configure_nano() {
   print_msg "Konfigurowanie nano..."
   
   # Instalacja podświetlania składni
   apt-get update
   apt-get install -y nano-syntax-highlighting
   
   # Tworzenie konfiguracji
   cat > ~/.nanorc << EOF
set autoindent
set tabsize 4
set tabstospaces
set linenumbers
set constantshow
set softwrap
include "/usr/share/nano/*.nanorc"
EOF

   print_success "Konfiguracja nano zakończona"
}

# Uruchomienie skryptu
check_root
configure_nano