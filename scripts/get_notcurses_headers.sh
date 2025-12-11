set -e

DEST="external/notcurses/include/notcurses"
mkdir -p "$DEST"

TMP=$(mktemp -d)

curl -L https://github.com/dankamongmen/notcurses/archive/refs/heads/master.zip -o "$TMP/notcurses.zip"
unzip -q "$TMP/notcurses.zip" -d "$TMP"

cp "$TMP"/notcurses-master/include/notcurses/*.h "$DEST"

echo "Notcurses headers updated in external/notcurses/include/notcurses"