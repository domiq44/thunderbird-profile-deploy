#!/usr/bin/env bash

# Purge automatique des anciennes sauvegardes Thunderbird
# Conserve les N sauvegardes les plus récentes
# Usage : ./purge_old_backups.sh [nombre_a_conserver]

set -e

BACKUP_DIR="$HOME/.thunderbird_backup"
KEEP="${1:-5}"   # Par défaut : conserver 5 sauvegardes

echo "📁 Dossier de sauvegarde : $BACKUP_DIR"
echo "🔢 Nombre de sauvegardes à conserver : $KEEP"

# Vérification du dossier
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Aucun dossier de sauvegarde trouvé."
    exit 1
fi

# Liste des sauvegardes triées du plus récent au plus ancien
BACKUPS=($(ls -1t "$BACKUP_DIR"))

TOTAL=${#BACKUPS[@]}

if [ "$TOTAL" -le "$KEEP" ]; then
    echo "✔️ Rien à purger : $TOTAL sauvegardes présentes (≤ $KEEP)"
    exit 0
fi

echo "🧮 Total des sauvegardes : $TOTAL"
echo "🗑️ Sauvegardes à supprimer : $((TOTAL - KEEP))"

# Sauvegardes à supprimer (les plus anciennes)
TO_DELETE=("${BACKUPS[@]:$KEEP}")

for backup in "${TO_DELETE[@]}"; do
    echo "❌ Suppression : $BACKUP_DIR/$backup"
    rm -rf "$BACKUP_DIR/$backup"
done

echo "✅ Purge terminée. Sauvegardes restantes : $KEEP"

