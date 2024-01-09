#!/bin/bash

cd /data/split-vpn/wireguard/protonvpn/ || exit

# Prerequisite checks
for cmd in curl jq wg; do
    if ! command -v "$cmd" &>/dev/null; then
        echo >&2 "$cmd required, but not installed. Install with 'apt install $cmd' (Debian/Ubuntu) or 'yum install $cmd' (CentOS/RHEL)."
        exit 1
    fi
done

apiurl="https://api.protonvpn.ch/vpn/logicals"
entrycountry="AT"
exitcountry="AT"
vpntier="2"

get_min_load_server() {
    local response=$(curl -s "$apiurl")
    [ -z "$response" ] && { echo "ERROR - API not responding or not reachable"; exit 1; }

    local server_data=$(echo "$response" | jq -c '.LogicalServers[] | select(.EntryCountry == "'$entrycountry'" and .ExitCountry == "'$exitcountry'" and .Tier == '$vpntier')')

    local min_load=101
    local min_load_server=""

    for data in $server_data; do
        local server=$(echo "$data" | jq -r '.Name')
        local load=$(echo "$data" | jq -r '.Load')

        if (( $(echo "$load < $min_load" | bc -l) )); then
            min_load="$load"
            min_load_server="$server"
        fi
    done

    [ -z "$min_load_server" ] && { echo "ERROR - server could not be extracted from the API"; exit 1; }
    echo "$min_load_server"
}

min_load_server=$(get_min_load_server)

config_path="/data/split-vpn/wireguard/protonvpn/configs"
cp "$config_path/wg0_${min_load_server}.conf" "$config_path/wg0.conf" && chmod 600 "$config_path/wg0.conf"

echo "Using server $min_load_server"
wg-quick up "$config_path/wg0.conf" | tee wireguard.log 2>&1
