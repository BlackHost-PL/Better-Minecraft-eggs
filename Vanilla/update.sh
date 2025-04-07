#!/bin/ash

AUTOMATIC_UPDATE="${AUTOMATIC_UPDATE:-0}"

if [ "$AUTOMATIC_UPDATE" != "1" ] && [ "$AUTOMATIC_UPDATE" != "true" ]; then
  echo "The update is disabled. The script will not perform it."
  exit 0
fi

VANILLA_VERSION="${VANILLA_VERSION:-latest}"

VERSION_MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"
VERSION_MANIFEST=$(curl -sSL "$VERSION_MANIFEST_URL")

if [ "$VANILLA_VERSION" = "latest" ]; then
  VANILLA_VERSION=$(echo "$VERSION_MANIFEST" | grep -o '"release": *"[^"]*"' | head -n1 | cut -d'"' -f4)
elif [ "$VANILLA_VERSION" = "snapshot" ]; then
  VANILLA_VERSION=$(echo "$VERSION_MANIFEST" | grep -o '"snapshot": *"[^"]*"' | head -n1 | cut -d'"' -f4)
fi

VERSION_URL=$(echo "$VERSION_MANIFEST" \
  | sed 's/},{/},\n{/g' \
  | grep -A3 -E "\"id\": *\"$VANILLA_VERSION\"" \
  | grep -o -E '"url": *"[^"]+"' \
  | head -n1 \
  | cut -d'"' -f4)

if [ -z "$VERSION_URL" ]; then
  echo "No VERSION_URL found for $VANILLA_VERSION"
  exit 1
fi

VERSION_JSON=$(curl -sSL "$VERSION_URL")
SERVER_JAR_URL=$(echo "$VERSION_JSON" | grep -o -E '"server": *\{[^}]+\}' | grep -o -E '"url": *"[^"]+"' | cut -d'"' -f4)

if [ -f $SERVER_JARFILE ]; then
  echo "Removing old $SERVER_JARFILE..."
  rm -f $SERVER_JARFILE
fi

echo "Downloading new $SERVER_JARFILE..."
curl -sSL -o $SERVER_JARFILE "$SERVER_JAR_URL" || {
  echo "Error downloading $SERVER_JARFILE"
  exit 1
}

echo "Done! Downloaded $SERVER_JARFILE for version $VANILLA_VERSION"