#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/var/log/system_optimization.log"

cleanup() {
    print_msg "Sprzątanie..."
    if [ -f /etc/default/grub.backup ]; then
        mv /etc/default/grub.backup /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
    exit 1
}

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

trap cleanup SIGINT SIGTERM

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Skrypt wymaga uprawnień roota"
        exit 1
    fi
}

check_grub() {
    if ! command -v grub-mkconfig &> /dev/null; then
        print_error "GRUB nie jest zainstalowany w systemie"
        return 1
    fi
    
    if [ ! -f /etc/default/grub ]; then
        print_error "Nie znaleziono pliku konfiguracyjnego GRUB"
        return 1
    fi
    
    return 0
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

optimize_power_management() {
    print_msg "Konfiguracja zarządzania energią..."
    
    for pkg in tlp tlp-rdw powertop thermald; do
        install_package "$pkg" || return 1
    done

    if ! systemctl enable --now tlp.service; then
        print_error "Nie udało się włączyć usługi TLP"
        return 1
    fi

    if ! systemctl enable --now thermald; then
        print_error "Nie udało się włączyć usługi thermald"
        return 1
    fi
    
    if ! powertop --calibrate; then
        print_error "Nie udało się skalibrować powertop"
        print_msg "Kontynuowanie bez kalibracji powertop..."
    fi

    print_success "Zarządzanie energią skonfigurowane"
}

optimize_cpu() {
    print_msg "Optymalizacja ustawień procesora..."
    
    if check_grub; then

        cp /etc/default/grub /etc/default/grub.backup

        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_pstate=enable pcie_aspm=force"/' /etc/default/grub
        
        if ! grub-mkconfig -o /boot/grub/grub.cfg; then
            print_error "Nie udało się zaktualizować konfiguracji GRUB"
            mv /etc/default/grub.backup /etc/default/grub
            return 1
        fi
    else
        print_msg "System nie używa GRUB. Pomijanie konfiguracji bootloadera..."
    fi

    if command -v yay &> /dev/null; then
        if ! yay -S --noconfirm auto-cpufreq; then
            print_error "Nie udało się zainstalować auto-cpufreq"
            return 1
        fi
        
        if ! systemctl enable --now auto-cpufreq; then
            print_error "Nie udało się włączyć usługi auto-cpufreq"
            return 1
        fi
    else
        print_msg "Nie znaleziono yay. Pomijam instalację auto-cpufreq"
    fi

    print_success "Optymalizacja procesora zakończona"
}

optimize_disk() {
    print_msg "Optymalizacja ustawień dysku..."

    if ! systemctl enable fstrim.timer; then
        print_error "Nie udało się włączyć timera fstrim"
        return 1
    fi
    
    if ! fstrim -v / > /tmp/fstrim.log 2>&1; then
        print_error "Wystąpił błąd podczas wykonywania fstrim"
        cat /tmp/fstrim.log >> "$LOG_FILE"
        print_msg "Szczegóły błędu zapisano w logu"
        return 1
    fi

    for disk in $(lsblk -d -o name | grep "sd"); do
        if hdparm -I "/dev/$disk" 2>/dev/null | grep -q "Advanced power management"; then
            if ! hdparm -B 1 "/dev/$disk"; then
                print_error "Nie udało się skonfigurować zarządzania energią dla /dev/$disk"
                continue
            fi
        fi
    done

    cat > /etc/udev/rules.d/69-hdparm.rules << EOF
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="/usr/bin/hdparm -B 1 /dev/%k"
EOF
    
    if ! grep -q "noatime" /etc/fstab; then
        print_msg "Dodawanie opcji noatime..."
        cp /etc/fstab /etc/fstab.backup
        if ! sed -i 's/defaults/defaults,noatime/g' /etc/fstab; then
            print_error "Nie udało się zmodyfikować /etc/fstab"
            mv /etc/fstab.backup /etc/fstab
            return 1
        fi
        
        if ! mount -o remount /; then
            print_error "Nie udało się przemontować systemu plików root"
            mv /etc/fstab.backup /etc/fstab
            return 1
        fi
        
        mount -o remount /boot 2>/dev/null || print_msg "Nie udało się przemontować /boot - to normalne jeśli nie jest osobną partycją"
    fi

    print_success "Optymalizacja dysku zakończona"
}

optimize_wifi() {
    print_msg "Optymalizacja ustawień WiFi..."
    
    for pkg in iwlwifi-ucode linux-firmware; do
        install_package "$pkg" || return 1
    done

    mkdir -p /etc/NetworkManager/conf.d/
    cat > /etc/NetworkManager/conf.d/wifi-powersave.conf << EOF
[connection]
wifi.powersave = 2
EOF
    
    cat > /etc/modprobe.d/iwlwifi.conf << EOF
options iwlwifi 11n_disable=8
options iwlwifi bt_coex_active=0
options iwlwifi swcrypto=1
options iwlwifi power_save=0
options iwlwifi 11n_disable=1
EOF
    
    if ! modprobe -r iwlwifi; then
        print_error "Nie udało się wyładować modułu iwlwifi"
        return 1
    fi
    
    if ! modprobe iwlwifi; then
        print_error "Nie udało się załadować modułu iwlwifi"
        return 1
    fi
    
    if ! systemctl restart NetworkManager; then
        print_error "Nie udało się zrestartować NetworkManager"
        return 1
    fi
    
    print_success "Optymalizacja WiFi zakończona"
}

main() {
    check_root
    
    print_msg "Rozpoczynam optymalizację systemu..."
    
    optimizations=(
        optimize_power_management
        optimize_cpu
        optimize_disk
        optimize_wifi
    )
    
    for opt in "${optimizations[@]}"; do
        if ! $opt; then
            print_error "Wystąpił błąd podczas wykonywania $opt"
            cleanup
        fi
    done
    
    print_success "Optymalizacja systemu zakończona. Proszę zrestartować system."

    if [ -f "$LOG_FILE" ]; then
        print_msg "Log z wykonanych operacji znajduje się w: $LOG_FILE"
    fi
}

main "$@"