#!/bin/bash
# Build ELF64 sql.so on Ubuntu. Does not touch /opt/samp or samp.service.
set -eu
cd "$(dirname "$0")"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y g++ make libmariadb-dev pkg-config
if command -v mariadb_config >/dev/null 2>&1; then
  echo "MARIADB_CONFIG=$(mariadb_config --include)"
  echo "MARIADB_LIBS=$(mariadb_config --libs)"
else
  echo "mariadb_config missing, pkg-config fallback"
  pkg-config --cflags --libs libmariadb || pkg-config --cflags --libs mariadb
fi
make clean || true
make
echo "==== file ===="
file bin/sql.so
echo "==== ldd ===="
ldd bin/sql.so
echo "==== exports ===="
nm -D bin/sql.so | grep -E '[[:space:]](Supports|Load|Unload|AmxLoad|AmxUnload|ProcessTick)$' || nm -D bin/sql.so | grep -E 'Supports|ProcessTick|AmxLoad'
