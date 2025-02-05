## Instrukcja instalcji dla Dell XPS 9333

Jest to przygotowna przezemnie pełna instrukcja instalacji Arch linux z użyiem skryptu archinstall oraz przygotwanego pliku instalacyjnego archinstall.json 

## Spis treści
- [Łączenie się z wifi](#-Łączenie się z wifi)
- [Instrukcja jak tego używać](#-Instrukcja jak tego używać)
- [Materiały pomocnicze](#-Materiały pomocnicze)  

## Łączenie się z wifi
Jeżeli masz podpięty internet po kablu to pomić ten krok, jeżeli nie to postępuj krok po kroku wedłóg tej instrukcji.

1. Wpis iwctl (jest to narzędzie do zarządzania połączeniami WiFi).
```bash
iwctl
```

2. Zobcz dostępne interfejscy wifi w twoim laptopie.
```bash
device list
```
najprawdopodobniej będzie się nazywać wlan0.

3. Włącz skanowanie w celu wyszukiwania sieci. 
```bash
station <device> scan
```
gdzie device to nazwa twojego interfejs.

4. Zobacz listę dostępnych sieci.
```bash
station <device> get-networks
```

5. Połącz się z wybraną siecią.
```bash
station <device> connect <SSID>
```
gdzie SSID to nazwa twojej sieci.


## Instrukcja jak tego używać
Po połączeniu z internetme 
## Materiały pomocnicze
https://www.freecodecamp.org/news/how-to-install-arch-linux/#how-to-set-the-console-keyboard-layout-and-font
