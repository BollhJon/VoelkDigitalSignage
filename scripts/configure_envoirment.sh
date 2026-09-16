#!/bin/bash
echo "======================================"
echo " Signage Konfiguration"
echo "======================================"
echo

# Welche Variablen sollen gesetzt werden?
echo "Welche Variablen sollen konfiguriert werden?"
echo "--------------------------------------"
echo "1) Tournament IDs"
echo "2) Start Mode"
echo "3) Beide"
echo

while true; do
    read -p "Auswahl [1/2/3]: " CONFIG_CHOICE

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

if [ "$SET_IDS" = true ]; then

    echo
    echo "Tournament IDs eingeben"
    echo "--------------------------------------"

    IDS=()

    while true; do
        read -p "Tournament ID: " ID

        # Leere Eingaben ignorieren
        if [ -z "$ID" ]; then
            echo "Keine ID eingegeben."
            continue
        fi

        IDS+=("$ID")

        read -p "Weitere ID hinzufügen? [j/n]: " MORE

        if [[ "$MORE" != "j" && "$MORE" != "J" ]]; then
            break
        fi
    done

    # IDs mit ; verbinden
    TOURNAMENT_IDS=$(IFS=';'; echo "${IDS[*]}")

fi


# ======================================
# Start Mode
# ======================================

if [ "$SET_MODE" = true ]; then

    echo
    echo "Start Mode"
    echo "--------------------------------------"
    echo "1) TURNIER"
    echo "2) SPONSORING"
    echo

    while true; do
        read -p "Auswahl [1/2]: " MODE_CHOICE

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

if [ "$SET_IDS" = true ]; then
    echo "SIGNAGE_TOURNAMENT_IDS=$TOURNAMENT_IDS"
fi

if [ "$SET_MODE" = true ]; then
    echo "SIGNAGE_MODE=$MODE"
fi

echo

read -p "Konfiguration speichern? [j/n]: " SAVE

if [[ "$SAVE" == "j" || "$SAVE" == "J" ]]; then

    # ==================================
    # Tournament IDs speichern
    # ==================================

    if [ "$SET_IDS" = true ]; then
        sudo sed -i '/^SIGNAGE_TOURNAMENT_IDS=/d' /etc/environment
        echo "SIGNAGE_TOURNAMENT_IDS=$TOURNAMENT_IDS" | sudo tee -a /etc/environment > /dev/null
    fi


    # ==================================
    # Start Mode speichern
    # ==================================

    if [ "$SET_MODE" = true ]; then
        sudo sed -i '/^SIGNAGE_MODE=/d' /etc/environment
        echo "SIGNAGE_MODE=$MODE" | sudo tee -a /etc/environment > /dev/null
    fi


    echo
    echo "Konfiguration wurde gespeichert."
    echo
    echo "Hinweis: Die neuen Umgebungsvariablen werden"
    echo "für neue Prozesse verfügbar. Eine bereits"
    echo "laufende Shell muss neu gestartet werden."

else

    echo
    echo "Konfiguration wurde NICHT gespeichert."

fi