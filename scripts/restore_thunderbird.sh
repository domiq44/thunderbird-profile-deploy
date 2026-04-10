#!/usr/bin/env bash

set -e

TB_DIR="$HOME/.thunderbird"
BACKUP_DIR="$HOME/.thunderbird_backup"

echo "🔍 Recherche de la dernière sauvegarde Thunderbird…"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Aucun dossier de sauvegarde trouvé : $BACKUP_DIR"
    exit 1
fi

LAST_BACKUP=$(ls -1 "$BACKUP_DIR" | sort -r | head -n 1)

if [ -z "$LAST_BACKUP" ]; then
    echo "❌ Aucune sauvegarde disponible."
    exit 1
fi

echo "📦 Dernière sauvegarde trouvée : $LAST_BACKUP"

BACKUP_PATH="$BACKUP_DIR/$LAST_BACKUP"

echo "⚠️  Le profil actuel va être supprimé et remplacé par la sauvegarde."
read -p "Continuer ? (o/N) " confirm

if [[ "$confirm" != "o" && "$confirm" != "O" ]]; then
    echo "❌ Restauration annulée."
    exit 1
fi

echo "🗑️ Suppression du profil actuel : $TB_DIR"
rm -rf "$TB_DIR"

echo "♻️ Restauration depuis : $BACKUP_PATH"
cp -a "$BACKUP_PATH" "$TB_DIR"

echo "🔐 Restauration des permissions"
chmod -R 700 "$TB_DIR"

echo "✅ Restauration terminée avec succès !"
echo "📁 Profil restauré depuis : $BACKUP_PATH"

