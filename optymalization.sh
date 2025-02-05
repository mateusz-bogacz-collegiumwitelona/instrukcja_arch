#!/bin/bash

# Kolory do wyświetlania
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funkcje pomocnicze
print_msg() { echo -e "${BLUE}[*]${NC} $1"; }
print_success() { echo -e "${GREEN}[+]${NC} $1"; }
print_error() { echo -e "${RED}[-]${NC} $1"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Skrypt wymaga uprawnień roota"
        exit 1
    fi
}

install_package() {
    if ! pacman -Qi "$1" &> /dev/null; then
        print_msg "Instalacja $1..."
        if pacman -S --noconfirm "$1"; then
            print_success "$1 zainstalowano pomyślnie"
        else
            print_error "Nie udało się zainstalować $1"
            return 1
        fi
    else
        print_msg "$1 jest już zainstalowany"
    fi
}

# Optymalizacja usług systemowych
optimize_power_management() {
    print_msg "Konfiguracja zarządzania energią..."
    
    for pkg in tlp tlp-rdw powertop thermald; do
        install_package "$pkg"
    done

    systemctl enable --now tlp.service
    systemctl enable --now thermald
    
    # Konfiguracja powertop
    powertop --calibrate

    print_success "Zarządzanie energią skonfigurowane"
}

optimize_cpu() {
    print_msg "Optymalizacja ustawień procesora..."
    
    # Aktualizacja parametrów GRUB
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_pstate=enable pcie_aspm=force"/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    
    # Instalacja i konfiguracja auto-cpufreq
    if command -v yay &> /dev/null; then
        yay -S --noconfirm auto-cpufreq
        systemctl enable --now auto-cpufreq
    else
        print_error "Nie znaleziono yay. Pomijam instalację auto-cpufreq"
    fi

    print_success "Optymalizacja procesora zakończona"
}

optimize_disk() {
    print_msg "Optymalizacja ustawień dysku..."
    
    # Włączenie TRIM dla SSD
    systemctl enable --now fstrim.timer
    fstrim -v /
    
    # Konfiguracja zarządzania energią dysków
    for disk in $(lsblk -d -o name | grep "sd"); do
        if hdparm -I "/dev/$disk" | grep -q "Advanced power management"; then
            hdparm -B 1 "/dev/$disk"
        fi
    done
    
    # Utworzenie reguły udev dla zarządzania energią HDD
    cat > /etc/udev/rules.d/69-hdparm.rules << EOF
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="/usr/bin/hdparm -B 1 /dev/%k"
EOF
    
    # Optymalizacja opcji montowania
    if ! grep -q "noatime" /etc/fstab; then
        print_msg "Dodawanie opcji noatime..."
        sed -i 's/defaults/defaults,noatime/g' /etc/fstab
        mount -o remount /
        mount -o remount /boot 2>/dev/null
    fi

    print_success "Optymalizacja dysku zakończona"
}

optimize_wifi() {
    print_msg "Optymalizacja ustawień WiFi..."
    
    # Instalacja wymaganych pakietów
    for pkg in iwlwifi-ucode linux-firmware; do
        install_package "$pkg"
    done
    
    # Konfiguracja zarządzania energią WiFi
    cat > /etc/NetworkManager/conf.d/wifi-powersave.conf << EOF
[connection]
wifi.powersave = 2
EOF
    
    # Konfiguracja opcji iwlwifi
    cat > /etc/modprobe.d/iwlwifi.conf << EOF
options iwlwifi 11n_disable=8
options iwlwifi bt_coex_active=0
options iwlwifi swcrypto=1
options iwlwifi power_save=0
options iwlwifi 11n_disable=1
EOF
    
    # Przeładowanie modułów WiFi
    modprobe -r iwlwifi
    modprobe iwlwifi
    
    systemctl restart NetworkManager
    
    print_success "Optymalizacja WiFi zakończona"
}

main() {
    check_root
    
    print_msg "Rozpoczynam optymalizację systemu..."
    
    optimize_power_management
    optimize_cpu
    optimize_disk
    optimize_wifi
    
    print_success "Optymalizacja systemu zakończona. Proszę zrestartować system."
}

main "$@"