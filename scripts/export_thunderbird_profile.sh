#!/usr/bin/env bash
#
# Export d’un profil Thunderbird modèle (version améliorée)
# ---------------------------------------------------------
# - Détection automatique du profil (Install / ProfileX)
# - Exclusion renforcée des données sensibles
# - Export propre et reproductible
# - Compatible Fedora / ESR / non-ESR
#

set -euo pipefail

echo "=== Export du profil Thunderbird modèle ==="

TB_DIR="$HOME/.thunderbird"
PROFILES_INI="$TB_DIR/profiles.ini"
INSTALLS_INI="$TB_DIR/installs.ini"

# ---------------------------------------------------------------------------
# 1. Vérifications préalables
# ---------------------------------------------------------------------------

if ! command -v thunderbird >/dev/null 2>&1; then
    echo "Erreur : Thunderbird n'est pas installé."
    exit 1
fi

if [ ! -f "$PROFILES_INI" ]; then
    echo "Erreur : $PROFILES_INI introuvable."
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Détection du profil actif
# ---------------------------------------------------------------------------

detect_profile() {
    # Méthode 1 : section [InstallXXXX]
    local p
    p=$(awk -F= '/^\[Install/ {f=1; next} f && /^Default=/ {print $2; exit}' "$PROFILES_INI")
    if [ -n "$p" ]; then
        echo "$p"
        return
    fi

    # Méthode 2 : section [Profile0]
    p=$(awk -F= '/^\[Profile0\]/ {f=1; next} f && /^Path=/ {print $2; exit}' "$PROFILES_INI")
    if [ -n "$p" ]; then
        echo "$p"
        return
    fi

    echo ""
}

PROFILE_PATH=$(detect_profile)

if [ -z "$PROFILE_PATH" ]; then
    echo "Erreur : impossible de détecter le profil Thunderbird."
    exit 1
fi

FULL_PROFILE_PATH="$TB_DIR/$PROFILE_PATH"

if [ ! -d "$FULL_PROFILE_PATH" ]; then
    echo "Erreur : le répertoire de profil n'existe pas : $FULL_PROFILE_PATH"
    exit 1
fi

echo "Profil détecté : $FULL_PROFILE_PATH"

# ---------------------------------------------------------------------------
# 3. Détection automatique du dossier Ansible
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANSIBLE_ROOT="$(dirname "$SCRIPT_DIR")"

EXPORT_BASE="$ANSIBLE_ROOT/roles/thunderbird_profile/files"
EXPORT_PROFILE="$EXPORT_BASE/thunderbird_profile/default-release"

echo "Export vers : $EXPORT_PROFILE"

# ---------------------------------------------------------------------------
# 4. Nettoyage de l'ancien export
# ---------------------------------------------------------------------------

rm -rf "$EXPORT_PROFILE"
mkdir -p "$EXPORT_PROFILE"

# ---------------------------------------------------------------------------
# 5. Export du profil modèle
# ---------------------------------------------------------------------------

echo "=== Export du profil (sans données sensibles) ==="

rsync -av \
  --exclude 'logins.json' \
  --exclude 'logins-backup.json' \
  --exclude 'logins.db' \
  --exclude 'key4.db' \
  --exclude 'cert9.db' \
  --exclude 'cookies.sqlite*' \
  --exclude 'webappsstore.sqlite*' \
  --exclude 'global-messages-db.sqlite*' \
  --exclude 'places.sqlite*' \
  --exclude 'session.json*' \
  --exclude 'sessionCheckpoints.json' \
  --exclude 'times.json' \
  --exclude 'crashes/' \
  --exclude 'minidumps/' \
  --exclude 'saved-telemetry-pings/' \
  --exclude 'datareporting/' \
  --exclude 'Mail/' \
  --exclude 'ImapMail/' \
  --exclude 'openpgp.sqlite' \
  --exclude 'encrypted-openpgp-passphrase.txt*' \
  --exclude '*.sqlite-wal' \
  --exclude '*.sqlite-shm' \
  --exclude 'lock' \
  --exclude '.parentlock' \
  "$FULL_PROFILE_PATH/" \
  "$EXPORT_PROFILE/"

echo "=== Export du profil terminé ==="

# ---------------------------------------------------------------------------
# 6. Export de profiles.ini et installs.ini
# ---------------------------------------------------------------------------

cp "$PROFILES_INI" "$EXPORT_BASE/profiles.ini"
cp "$INSTALLS_INI" "$EXPORT_BASE/installs.ini"

echo "=== Export terminé ==="
echo "Profil modèle : $EXPORT_PROFILE"
