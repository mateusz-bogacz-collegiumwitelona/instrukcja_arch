# Instrukcja instalacji dla Dell XPS 9333

Jest to przygotowana przeze mnie pełna instrukcja instalacji Arch Linux z użyciem skryptu archinstall oraz przygotowanego pliku instalacyjnego archinstall.json.

## Spis treści
- [Opis skryptów](#opis-skryptów)
- [Łączenie się z WiFi](#łączenie-się-z-wifi)
- [Instalacja systemu z pomocą archinstall.json](#instalacja-systemu-z-pomocą-archinstalljson)
- [Instalacja yay](#instalacja-yay)
- [Materiały pomocnicze](#materiały-pomocnicze)

## Opis skryptów

### archinstall.json

#### Podstawowa konfiguracja systemu
- **Język i lokalizacja**
  - System: Polski (pl_PL.UTF-8)
  - Klawiatura: pl
  - Strefa czasowa: Europa/Warszawa
  - Kodowanie: UTF-8

#### Konfiguracja sprzętowa
- **Dysk (/dev/sda)**
  - Partycja boot: 1GB (FAT32, flagi: boot, esp)
  - Partycja root: pozostała przestrzeń (ext4)
- **Audio:** PipeWire
- **Sterowniki graficzne:** Intel (open-source)
- **Bootloader:** GRUB

#### Środowisko graficzne
- **Desktop:** GNOME
- **Display Manager:** GDM
- **Network Manager:** enabled

#### Repozytoria i pakiety
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

### yay_install.sh

#### Funkcje bezpieczeństwa
- Weryfikacja uprawnień roota
- Bezpieczna instalacja jako użytkownik nierootowy
- Obsługa błędów instalacji

#### Instalowane oprogramowanie
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
- **Narzędzia systemowe:**
  ```
  auto-cpufreq
  ```

#### Cechy skryptu
- Kolorowe komunikaty statusu (success, error, info)
- Automatyczna instalacja yay
- Weryfikacja istniejących pakietów
- Automatyczna aktualizacja systemu przed instalacją
- Tworzenie dedykowanego katalogu na pakiety (~/paczki)

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

## Materiały pomocnicze

[Jak zainstalować Arch Linux (freeCodeCamp)](https://www.freecodecamp.org/news/how-to-install-arch-linux/#how-to-set-the-console-keyboard-layout-and-font)