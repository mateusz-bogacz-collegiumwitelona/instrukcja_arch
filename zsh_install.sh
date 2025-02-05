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

# Sprawdzenie argumentu z plikiem p10k.zsh
if [ "$#" -ne 1 ]; then
   print_error "Użycie: ./skrypt.sh ścieżka/do/p10k.zsh"
   exit 1
fi

print_msg "Instalowanie ZSH..."
sudo pacman -S zsh --noconfirm

# Zmiana domyślnej powłoki
chsh -s /bin/zsh

print_msg "Sprawdzanie czy ZSH jest zainstalowane..."
if [ "$SHELL" = "/bin/zsh" ]; then
   print_success "ZSH zostało zainstalowane pomyślnie"
else
   print_error "Instalacja ZSH nie powiodła się"
   exit 1
fi

print_msg "Instalowanie Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

print_msg "Instalowanie wtyczek ZSH..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

sudo pacman -S fzf --noconfirm

print_msg "Konfigurowanie wtyczek ZSH..."
PLUGINS="plugins=(git asdf zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting extract dirhistory systemd fzf z)"

cp ~/.zshrc ~/.zshrc.backup
sed -i "/^plugins=(.*)/c\\$PLUGINS" ~/.zshrc

print_msg "Dodawanie aliasu update..."
echo "alias update='sudo pacman -Syu --noconfirm && yay -Syu --noconfirm'" >> ~/.zshrc

print_msg "Instalowanie motywu Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
cp "$1" ~/.p10k.zsh

print_success "Instalacja zakończona pomyślnie"