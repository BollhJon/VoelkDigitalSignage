# Völk Digital Signage

Lokale Digital-Signage für Raspberry Pi. Der Flask-Server liefert eine lokal gespeicherte, reveal.js-kompatible Präsentation aus, Chromium zeigt sie im Kiosk-Modus an.

## URLs

| URL | Inhalt |
| --- | --- |
| `/` | Weiterleitung auf definierte URL |
| `/turnier` | Gruppenphase und Finalspiele |
| `/group` | Nur Gruppenphase |
| `/finale` | Nur Finalspiele |
| `/sponsoring` | Nur Sponsor-Bilder |

Die Turnierfolien betten die offiziellen Widgets von meinturnierplan.de ein. Aktuelle Ergebnisse erscheinen direkt im Kiosk, solange der Raspberry Pi Internetzugang hat.
Jede Gruppe erhält eine eigene Folie mit ihrer Rangliste und allen Spielen dieser Gruppe.

## Installation

```bash
git clone https://github.com/BollhJon/VoelkDigitalSignage.git
cd VoelkDigitalSignage
bash scripts/install.sh
```

## Betrieb prüfen

```bash
systemctl status signage
journalctl -u signage -f
curl http://127.0.0.1:8000/health
```

## Kiosk schliessen

```bash
pkill -o chromium
```

## Service neustarten

```bash
sudo systemctl daemon-reload
sudo systemctl restart signage.service
```