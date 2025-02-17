# Skrypty i instrukcja instalacji ArchLinux

Jest to przygotowana przeze mnie pełna instrukcja instalacji Arch Linux z użyciem skryptu archinstall oraz przygotowanego pliku instalacyjnego archinstall.json.

## Spis treści

- [Łączenie się z WiFi](#łączenie-się-z-wifi)
- [Instalacja systemu z pomocą archinstall.json](#instalacja-systemu-z-pomocą-archinstalljson)
- [Instalacja yay](#instalacja-yay)
- [Optymalizacja pacman i yay](#optymalizacja-pacman-i-yay)
- [Usuwanie niepotrzebnych pakietów](#usuwanie-niepotrzebnych-pakietów)
- [Instalowanie ZSH, OhMyZSH, powerlevel10k i dodatków](#instalowanie-zsh-ohmyzsh-powerlevel10k-i-dodatków)
- [Optymalizacja nano](#optymalizacja-nano)
- [Optymalizacja systemu](#optymalizacja-systemu)
- [Materiały pomocnicze](#materiały-pomocnicze)

## Łączenie się z WiFi

Jeżeli masz podpięty internet po kablu, możesz pominąć ten krok. W przeciwnym razie postępuj według poniższej instrukcji:

1. Wpisz iwctl (jest to narzędzie do zarządzania połączeniami WiFi):

```bash
iwctl
```

2. Zobacz dostępne interfejsy WiFi w twoim laptopie:

```bash
device list
```

Najprawdopodobniej będzie się nazywać wlan0.

3. Włącz skanowanie w celu wyszukiwania sieci:

```bash
station <device> scan
```

gdzie `<device>` to nazwa twojego interfejsu.

4. Zobacz listę dostępnych sieci:

```bash
station <device> get-networks
```

5. Połącz się z wybraną siecią:

```bash
station <device> connect <SSID>
```

gdzie `<SSID>` to nazwa twojej sieci.

## Instalacja systemu z pomocą archinstall.json

Jest to skrypt ułatwiający instalowanie ArchLinux który ustawia:

### Podstawowa konfiguracja

- **Język i lokalizacja**
  - System: Polski (pl_PL.UTF-8)
  - Klawiatura: pl
  - Strefa czasowa: Europa/Warszawa
  - Kodowanie: UTF-8

### Konfiguracja sprzętowa

- **Dysk (/dev/sda)**
  - Partycja boot: 1GB (FAT32, flagi: boot, esp)
  - Partycja root: pozostała przestrzeń (ext4)
- **Audio:** PipeWire
- **Sterowniki graficzne:** Intel (open-source)
- **Bootloader:** GRUB

### Środowisko graficzne

- **Desktop:** GNOME
- **Display Manager:** GDM
- **Network Manager:** enabled

### Repozytoria i pakiety

- **Dodatkowe repozytoria:**
  - multilib
  - testing
- **Podstawowe pakiety:**
  ```
  git, htop, vlc, geany, firefox,
  gparted, libreoffice-still,
  neofetch, curl, wget
  ```
- **Serwery lustrzane:** Polskie (ICM, midov.pl)

### Użycie

Po połączeniu z internetem należy pobrać skrypt instalacyjny archinstall.json:

1. Pobierz curl:

```bash
pacman -Sy curl
```

2. Pobierz plik konfiguracyjny:

```bash
curl -O https://raw.githubusercontent.com/mateusz-bogacz-collegiumwitelona/instrukcja_arch/main/archinstall.json
```

3. Sprawdź czy plik został pobrany:

```bash
ls archinstall.json
```

Jeżeli nie, ponów próbę.

4. Rozpocznij instalację za pomocą archinstall:

```bash
archinstall --config archinstall.json
```

Instalator może zapytać o dodatkowe informacje, jeśli nie wszystkie wymagane parametry są zdefiniowane w pliku (np. konto roota czy użytkownika).

Po zakończeniu instalacji zrestartuj komputer:

```bash
reboot now
```

## Instalacja yay

Ten skrypt ma na celu:

### Funkcje bezpieczeństwa

- Weryfikacja uprawnień roota
- Bezpieczna instalacja jako użytkownik nierootowy
- Obsługa błędów instalacji

### Instalowane oprogramowanie

- **IDE i edytory:**
  ```
  intellij-idea-ultimate-edition
  phpstorm
  pycharm-professional
  visual-studio-code-bin
  ```
- **Przeglądarka:**
  ```
  google-chrome
  ```
- **Komunikator:**
  ```
  discord
  ```

### Cechy skryptu

- Kolorowe komunikaty statusu (success, error, info)
- Automatyczna instalacja yay
- Weryfikacja istniejących pakietów
- Automatyczna aktualizacja systemu przed instalacją
- Tworzenie dedykowanego katalogu na pakiety (~/paczki)

### Użycie

1. Pobierz skrypt:

```bash
curl -O https://raw.githubusercontent.com/mateusz-bogacz-collegiumwitelona/instrukcja_arch/main/yay_install.sh
```

2. Nadaj uprawnienia wykonywania:

```bash
chmod +x yay_install.sh
```

3. Uruchom jako root:

```bash
sudo ./yay_install.sh
```

## Optymalizacja pacman i yay

Skrypt optymalizujący działanie pacman i yay w systemie Arch Linux.

### Funkcje

- Włącza kolorowe wyjście w pacman
- Aktywuje animację PacMan podczas pobierania (ILoveCandy)
- Konfiguruje równoległe pobieranie (do 5 plików)
- Optymalizuje ustawienia yay (czyszczenie cache, usuwanie zależności kompilacji)

### Użycie

1. Pobierz skrypt optymalizacyjny:

```bash
curl -O https://raw.githubusercontent.com/user/repo/main/installing_optymalization.sh
curl -O https://raw.githubusercontent.com/user/repo/main/my_pacman
```

2. Nadaj uprawnienia:

```bash
chmod +x installing_optymalization.sh
```

3. Uruchom:

```bash
sudo ./installing_optymalization.sh my_pacman
```

## Usuwanie niepotrzebnych pakietów

Skrypt automatyzujący usuwanie domyślnych aplikacji GNOME z systemu Arch Linux.

### Funkcje bezpieczeństwa

- Weryfikacja uprawnień roota
- Sprawdzanie istnienia pakietów
- Obsługa błędów usuwania

### Usuwane pakiety

```bash
epiphany
gnome-contacts
gnome-maps
totem
malcontent
gnome-tour
gnome-user-docs
gnome-weather
```

### Cechy

- Kolorowe komunikaty statusu (success, error, info)
- Automatyczne usuwanie bez potwierdzenia (--noconfirm)
- Usuwanie rekursywne z zależnościami (-Rns)
- Weryfikacja pakietów przed usunięciem

### Użycie

1. Pobierz skrypt:

```bash
curl -O https://raw.githubusercontent.com/mateusz-bogacz-collegiumwitelona/instrukcja_arch/main/remove.sh
```

2. Nadaj uprawnienia wykonywania:

```bash
chmod +x remove.sh
```

3. Uruchom jako root:

```bash
sudo ./remove.sh
```

## Instalowanie ZSH, OhMyZSH, powerlevel10k i dodatków

Skrypt instalujący ZSH z Oh My Zsh, Powerlevel10k i przydatnymi wtyczkami.

### Instalowane komponenty

#### Główne

- **ZSH** - zaawansowana powłoka z wieloma funkcjami
- **Oh My Zsh** - framework do zarządzania konfiguracją ZSH
- **Powerlevel10k** - szybki i konfigurowalny motyw z bogatą personalizacją

#### Wtyczki

- **zsh-autosuggestions** - podpowiadanie komend na podstawie historii
- **zsh-completions** - rozszerzone uzupełnianie dla wielu programów
- **zsh-history-substring-search** - wyszukiwanie w historii przez PageUp/Down
- **zsh-syntax-highlighting** - kolorowanie składni podczas pisania
- **asdf** - uniwersalny menedżer wersji (Node.js, Python, Ruby itp.)
- **fzf** - fuzzy finder - wyszukiwanie plików/historii
- **extract** - rozpakowywanie archiwów jedną komendą
- **dirhistory** - nawigacja katalogów Alt+lewo/prawo
- **systemd** - zarządzanie usługami systemd
- **z** - szybkie przechodzenie do często używanych katalogów

### Użycie

1. Pobierz skrypt i plik konfiguracyjny:

```bash
curl -O https://raw.githubusercontent.com/mateusz-bogacz-collegiumwitelona/instrukcja_arch/main/zsh_install.sh
curl -O https://raw.githubusercontent.com/mateusz-bogacz-collegiumwitelona/instrukcja_arch/main/my_p10k
curl -O https://raw.githubusercontent.com/mateusz-bogacz-collegiumwitelona/instrukcja_arch/main/my_zsh
```

2. Nadaj uprawnienia:

```bash
chmod +x zsh_install.sh
```

3. Uruchom jako root:

```bash
sudo ./zsh_install.sh my_p10k my_zsh
```

## Optymalizacja nano

Skrypt konfigurujący i optymalizujący edytor nano w systemie Linux.

### Funkcje

- Instaluje podświetlanie składni dla nano
- Konfiguruje automatyczne wcięcia i numerowanie linii
- Ustawia optymalny rozmiar tabulatora (4 spacje)
- Aktywuje zawijanie długich linii
- Włącza konwersję tabulatorów na spacje
- Dodaje wszystkie dostępne definicje składni

### Użycie

1. Pobierz skrypt optymalizacyjny:

```bash
curl -O https://raw.githubusercontent.com/user/repo/main/nano_optymalization.sh
```

2. Nadaj uprawnienia:

```bash
chmod +x nano_optymalization.sh
```

3. Uruchom:

```bash
sudo ./nano_optymalization.sh
```

## Optymalizacja systemu

Skrypt automatyzujący optymalizację systemu dla laptopa Dell XPS 9333.

### Funkcje optymalizacji

#### Zarządzanie energią

- Instalacja i konfiguracja TLP, powertop i thermald
- Kalibracja powertop
- Automatyczna aktywacja usług

#### Procesor

- Optymalizacja parametrów GRUB (intel_pstate, pcie_aspm)
- Instalacja i konfiguracja auto-cpufreq
- Dostosowanie częstotliwości procesora

#### Dysk

- Aktywacja TRIM dla SSD
- Optymalizacja zarządzania energią HDD
- Konfiguracja opcji montowania (noatime)
- Tworzenie reguł udev

#### WiFi

- Instalacja sterowników iwlwifi
- Optymalizacja zarządzania energią
- Konfiguracja parametrów modułu iwlwifi

### Użycie

1. Pobierz skrypt:

```bash
curl -O https://raw.githubusercontent.com/mateusz-bogacz-collegiumwitelona/instrukcja_arch/main/system_optymalization.sh
```

2. Nadaj uprawnienia:

```bash
chmod +x system_optymalization.sh
```

3. Uruchom jako root:

```bash
sudo ./system_optymalization.sh
```

## Materiały pomocnicze

- [Jak zainstalować Arch Linux (freeCodeCamp)](https://www.freecodecamp.org/news/how-to-install-arch-linux/#how-to-set-the-console-keyboard-layout-and-font)
- [Jak zainstalować ZSH i powerlevel10k (davidtsadler)](https://davidtsadler.com/posts/arch/2020-09-07/installing-zsh-and-powerlevel10k-on-arch-linux/)
- [Jak zaisntalować OhMyZSH](https://ohmyz.sh/)