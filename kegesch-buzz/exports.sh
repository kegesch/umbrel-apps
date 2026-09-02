# kegesch-buzz exports.sh
# Sourced by umbreld's app-script (legacy-compat) before docker compose runs.
# Values exported here are available for ${VAR} interpolation in
# docker-compose.yml.

# User overrides live in the persistent data volume and survive app updates:
#   edit app-data/kegesch-buzz/data/buzz/relay.env
# e.g. to switch from Tailscale MagicDNS back to LAN mDNS:
#   BUZZ_RELAY_URL=ws://umbrel.local:2112
# NOTE: RELAY_URL is the community's identity (host + port must byte-match
# what clients use). Changing it re-seeds a FRESH, empty community.

if [ -f "${UMBREL_ROOT}/app-data/kegesch-buzz/data/buzz/relay.env" ]; then
  # shellcheck disable=SC1090
  . "${UMBREL_ROOT}/app-data/kegesch-buzz/data/buzz/relay.env"
fi

export BUZZ_RELAY_URL="${BUZZ_RELAY_URL:-ws://umbrel.taild90d7a.ts.net:2112}"
