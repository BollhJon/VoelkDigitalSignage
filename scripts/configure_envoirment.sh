#!/usr/bin/env bash

set -Eeuo pipefail

ENV_FILE="/etc/environment"
SERVICE_ENV_FILE="/etc/voelk-signage.env"

# ======================================
# Fehlerbehandlung
# ======================================

error_exit() {
    echo
    echo "FEHLER: $*" >&2
    exit 1
}

trap 'echo; echo "Konfiguration abgebrochen."' INT TERM

# ======================================
# Root / sudo prüfen
# ======================================

if ! command -v sudo >/dev/null 2>&1; then
    error_exit "sudo wurde nicht gefunden."
fi

if ! sudo -v; then
    error_exit "sudo-Berechtigung erforderlich."
fi

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Hinweis: $ENV_FILE existiert noch nicht."
    sudo touch "$ENV_FILE"
fi
if [[ ! -f "$SERVICE_ENV_FILE" ]]; then
    echo "Hinweis: $SERVICE_ENV_FILE existiert noch nicht."
    sudo touch "$SERVICE_ENV_FILE"
fi

# ======================================
# Header
# ======================================

echo "======================================"
echo " Signage Konfiguration"
echo "======================================"
echo

# ======================================
# Welche Variablen?
# ======================================

echo "Welche Variablen sollen konfiguriert werden?"
echo "--------------------------------------"
echo "1) Tournament IDs"
echo "2) Start Mode"
echo "3) Beide"
echo

while true; do
    read -r -p "Auswahl [1/2/3]: " CONFIG_CHOICE

    case "$CONFIG_CHOICE" in
        1)
            SET_IDS=true
            SET_MODE=false
            break
            ;;
        2)
            SET_IDS=false
            SET_MODE=true
            break
            ;;
        3)
            SET_IDS=true
            SET_MODE=true
            break
            ;;
        *)
            echo "Ungültige Auswahl. Bitte 1, 2 oder 3 eingeben."
            ;;
    esac
done

# ======================================
# Tournament IDs
# ======================================

if [[ "$SET_IDS" == true ]]; then

    echo
    echo "Tournament IDs eingeben"
    echo "--------------------------------------"

    IDS=()

    while true; do
        read -r -p "Tournament ID: " ID

        # Leere Eingaben ignorieren
        if [[ -z "$ID" ]]; then
            echo "Keine ID eingegeben."
            continue
        fi

        # Keine Whitespaces erlauben
        if [[ "$ID" =~ [[:space:]] ]]; then
            echo "Ungültige ID: Leerzeichen sind nicht erlaubt."
            continue
        fi

        # Semikolon verhindern, da es unser Trennzeichen ist
        if [[ "$ID" == *";"* ]]; then
            echo "Ungültige ID: ';' ist nicht erlaubt."
            continue
        fi

        # ID nur einmal aufnehmen
        DUPLICATE=false

        for EXISTING_ID in "${IDS[@]}"; do
            if [[ "$EXISTING_ID" == "$ID" ]]; then
                DUPLICATE=true
                break
            fi
        done

        if [[ "$DUPLICATE" == true ]]; then
            echo "Diese ID wurde bereits eingegeben."
            continue
        fi

        IDS+=("$ID")

        while true; do
            read -r -p "Weitere ID hinzufügen? [j/n]: " MORE

            case "${MORE,,}" in
                j|ja)
                    break
                    ;;
                n|nein)
                    break 2
                    ;;
                *)
                    echo "Bitte j oder n eingeben."
                    ;;
            esac
        done
    done

    # IDs mit ; verbinden
    TOURNAMENT_IDS=$(IFS=';'; printf '%s' "${IDS[*]}")

fi

# ======================================
# Start Mode
# ======================================

if [[ "$SET_MODE" == true ]]; then

    echo
    echo "Start Mode"
    echo "--------------------------------------"
    echo "1) TURNIER"
    echo "2) SPONSORING"
    echo

    while true; do
        read -r -p "Auswahl [1/2]: " MODE_CHOICE

        case "$MODE_CHOICE" in
            1)
                MODE="TURNIER"
                break
                ;;
            2)
                MODE="SPONSORING"
                break
                ;;
            *)
                echo "Ungültige Auswahl. Bitte 1 oder 2 eingeben."
                ;;
        esac
    done

fi

# ======================================
# Zusammenfassung
# ======================================

echo
echo "======================================"
echo " Folgende Konfiguration wird gesetzt:"
echo "======================================"

if [[ "$SET_IDS" == true ]]; then
    echo "SIGNAGE_TOURNAMENT_IDS=$TOURNAMENT_IDS"
fi

if [[ "$SET_MODE" == true ]]; then
    echo "SIGNAGE_MODE=$MODE"
fi

echo

# ======================================
# Speichern bestätigen
# ======================================

while true; do
    read -r -p "Konfiguration speichern? [j/n]: " SAVE

    case "${SAVE,,}" in
        j|ja)
            break
            ;;
        n|nein)
            echo
            echo "Konfiguration wurde NICHT gespeichert."
            exit 0
            ;;
        *)
            echo "Bitte j oder n eingeben."
            ;;
    esac
done

# ======================================
# Backup erstellen
# ======================================

BACKUP_FILE="${ENV_FILE}.backup.$(date '+%Y%m%d-%H%M%S')"
SERVICE_BACKUP_FILE="${SERVICE_ENV_FILE}.backup.$(date '+%Y%m%d-%H%M%S')"

echo
echo "Erstelle Backup..."

sudo cp -- "$ENV_FILE" "$BACKUP_FILE"
sudo cp -- "$SERVICE_ENV_FILE" "$SERVICE_BACKUP_FILE"

echo "Backup: $BACKUP_FILE"
echo "Backup: $SERVICE_BACKUP_FILE"


# ======================================
# Neue /etc/environment erzeugen
# ======================================

TEMP_FILE=$(mktemp)

cleanup() {
    rm -f -- "$TEMP_FILE"
}

trap cleanup EXIT

# Bestehende Datei übernehmen,
# aber die zu konfigurierenden Variablen entfernen.
sudo cp -- "$ENV_FILE" "$TEMP_FILE"

if [[ "$SET_IDS" == true ]]; then
    sed -i '/^[[:space:]]*SIGNAGE_TOURNAMENT_IDS=/d' "$TEMP_FILE"
fi

if [[ "$SET_MODE" == true ]]; then
    sed -i '/^[[:space:]]*SIGNAGE_MODE=/d' "$TEMP_FILE"
fi

# Neue Werte anhängen
if [[ "$SET_IDS" == true ]]; then
    printf 'SIGNAGE_TOURNAMENT_IDS=%s\n' "$TOURNAMENT_IDS" >> "$TEMP_FILE"
fi

if [[ "$SET_MODE" == true ]]; then
    printf 'SIGNAGE_MODE=%s\n' "$MODE" >> "$TEMP_FILE"
fi

# ======================================
# Datei atomar ersetzen
# ======================================

sudo install -m 644 "$TEMP_FILE" "$ENV_FILE"
sudo install -m 644 "$TEMP_FILE" "$SERVICE_ENV_FILE"

# ======================================
# Abschluss
# ======================================

echo
echo "======================================"
echo " Konfiguration gespeichert"
echo "======================================"
echo
echo "Aktuelle Werte:"
echo

if [[ "$SET_IDS" == true ]]; then
    echo "SIGNAGE_TOURNAMENT_IDS=$TOURNAMENT_IDS"
fi

if [[ "$SET_MODE" == true ]]; then
    echo "SIGNAGE_MODE=$MODE"
fi

echo
echo "Hinweis:"
echo "Die Änderungen gelten für neue Prozesse."
echo "Bereits laufende Prozesse übernehmen die"
echo "neuen Umgebungsvariablen nicht automatisch."
echo