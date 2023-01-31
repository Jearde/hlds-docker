#!/usr/bin/env bash

set -axe

STEAMAPPDIR=/opt/steam/hlds
CONFIG_FILE="${STEAMAPPDIR}/startup.cfg"

if [ -r "${CONFIG_FILE}" ]; then
    # TODO: make config save/restore mechanism more solid
    set +e
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
    set -e
fi

EXTRA_OPTIONS=( "$@" )

EXECUTABLE="${STEAMAPPDIR}/hlds_run"
GAME="${GAME:-cstrike}"
MAXPLAYERS="${MAXPLAYERS:-20}"
START_MAP="${START_MAP:-bounce}"
SERVER_NAME="${SERVER_NAME:-'Counter Strike 1.6 Server'}"
INSECURE="${INSECURE:-}"
NOMASTERS="${NOMASTERS:-}"

OPTIONS=("-game" "${GAME}" "+maxplayers" "${MAXPLAYERS}" "+map" "${START_MAP}" "+hostname" "\"${SERVER_NAME}\"" "${INSECURE}" "${NOMASTERS}")

set > "${CONFIG_FILE}"

exec python3 -m http.server --directory ${STEAMAPPDIR}/cstrike 8080 &
exec "${EXECUTABLE}" "${OPTIONS[@]}" "${EXTRA_OPTIONS[@]}"
