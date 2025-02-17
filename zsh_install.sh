#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/var/log/zsh_install.log"

cleanup() {
   print_msg "Sprzątanie..."
   if [ -f ~/.zshrc.new ]; then
      rm ~/.zshrc.new
   fi
   if [ -f ~/.p10k.zsh.new ]; then
      rm ~/.p10k.zsh.new
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

if [ "$#" -ne 2 ]; then
   print_error "Użycie: $0 ścieżka/do/zshrc ścieżka/do/p10k.zsh"
   exit 1
fi

if [ -z "$SUDO_USER" ]; then
   print_error "Skrypt musi być uruchomiony przez sudo"
   exit 1
fi

zshrc_file=$1
p10k_file=$2

if [ ! -f "$zshrc_file" ]; then
   print_error "Plik $zshrc_file nie istnieje"
   exit 1
fi

if [ ! -f "$p10k_file" ]; then
   print_error "Plik $p10k_file nie istnieje"
   exit 1
fi

check_dependencies() {
   local dependencies=("git" "curl" "zsh")
    
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

install_zsh() {
   print_msg "Instalowanie ZSH..."
    
   if ! chsh -s "$(which zsh)" "$SUDO_USER"; then
      print_error "Nie udało się zmienić powłoki na ZSH"
      return 1
   fi

   if ! grep -q "$(which zsh)" "/etc/passwd"; then
      print_error "Nie udało się zweryfikować zmiany powłoki"
      return 1
   fi

   print_success "ZSH zostało zainstalowane pomyślnie"
   return 0
}

install_oh_my_zsh() {
   print_msg "Instalowanie Oh My Zsh..."
    
   if [ -d "/home/$SUDO_USER/.oh-my-zsh" ]; then
      sudo -u "$SUDO_USER" rm -rf "/home/$SUDO_USER/.oh-my-zsh"
   fi

   if ! sudo -u "$SUDO_USER" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
      print_error "Nie udało się zainstalować Oh My Zsh"
      return 1
   fi

   print_success "Oh My Zsh zostało zainstalowane"
   return 0
}

install_plugins() {
   print_msg "Instalowanie wtyczek ZSH..."
    
   local plugins=(
      "https://github.com/zsh-users/zsh-autosuggestions"
      "https://github.com/zsh-users/zsh-completions"
      "https://github.com/zsh-users/zsh-history-substring-search"
      "https://github.com/zsh-users/zsh-syntax-highlighting"
   )

   local custom_dir="/home/$SUDO_USER/.oh-my-zsh/custom/plugins"
    
   for plugin_url in "${plugins[@]}"; do
      local plugin_name=$(basename "$plugin_url")
      if [ -d "$custom_dir/$plugin_name" ]; then
         sudo -u "$SUDO_USER" rm -rf "$custom_dir/$plugin_name"
      fi
        
      if ! sudo -u "$SUDO_USER" git clone "$plugin_url" "$custom_dir/$plugin_name"; then
         print_error "Nie udało się zainstalować wtyczki $plugin_name"
         return 1
      fi
   done

   if [ -d "/home/$SUDO_USER/.asdf" ]; then
      sudo -u "$SUDO_USER" rm -rf "/home/$SUDO_USER/.asdf"
   fi
    
   if ! sudo -u "$SUDO_USER" git clone https://github.com/asdf-vm/asdf.git "/home/$SUDO_USER/.asdf"; then
      print_error "Nie udało się zainstalować asdf"
      return 1
   fi

   print_success "Wtyczki zostały zainstalowane"
   return 0
}

install_powerlevel10k() {
   print_msg "Instalowanie motywu Powerlevel10k..."
    
   local theme_dir="/home/$SUDO_USER/.oh-my-zsh/custom/themes/powerlevel10k"
    
   if [ -d "$theme_dir" ]; then
      sudo -u "$SUDO_USER" rm -rf "$theme_dir"
   fi
    
   if ! sudo -u "$SUDO_USER" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"; then
      print_error "Nie udało się zainstalować Powerlevel10k"
      return 1
   fi

   print_success "Powerlevel10k został zainstalowany"
   return 0
}

update_config_files() {
   print_msg "Aktualizowanie plików konfiguracyjnych..."

   if [ -f "/home/$SUDO_USER/.zshrc" ]; then
      sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/.zshrc" "/home/$SUDO_USER/.zshrc.old"
   fi
    
   if [ -f "/home/$SUDO_USER/.p10k.zsh" ]; then
      sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/.p10k.zsh" "/home/$SUDO_USER/.p10k.zsh.old"
   fi

   if ! sudo -u "$SUDO_USER" cp "$zshrc_file" "/home/$SUDO_USER/.zshrc"; then
      print_error "Nie udało się skopiować pliku .zshrc"
      return 1
   fi
    
   if ! sudo -u "$SUDO_USER" cp "$p10k_file" "/home/$SUDO_USER/.p10k.zsh"; then
      print_error "Nie udało się skopiować pliku .p10k.zsh"
      return 1
   fi

   print_success "Pliki konfiguracyjne zostały zaktualizowane"
   return 0
}

main() {
   print_msg "Rozpoczynam instalację ZSH i konfigurację..."

   if ! check_dependencies; then
      print_error "Nie udało się zainstalować wymaganych zależności"
      cleanup
      exit 1
   fi

   local steps=(
      install_zsh
      install_oh_my_zsh
      install_plugins
      install_powerlevel10k
      update_config_files
   )

   for step in "${steps[@]}"; do
      if ! $step; then
         print_error "Wystąpił błąd podczas wykonywania kroku: $step"
         cleanup
         exit 1
      fi
    done

   print_success "Instalacja zakończona pomyślnie"
   print_msg "Kopie zapasowe plików konfiguracyjnych znajdują się w:"
   print_msg "- /home/$SUDO_USER/.zshrc.old"
   print_msg "- /home/$SUDO_USER/.p10k.zsh.old"
   print_msg "Proszę wylogować się i zalogować ponownie, aby zastosować zmiany"
}

main