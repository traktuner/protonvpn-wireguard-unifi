#!/bin/bash

# navigate to folder containing the files
cd /data/split-vpn/wireguard/protonvpn/

# check for prerequisites
command -v curl >/dev/null 2>&1 || { echo >&2 "curl required, but not installed. install with 'apt install curl' (debian/ubuntu) or 'yum install curl' (centos/rhel)."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "jq required, but not installed. install with  'apt install jq' (debian/ubuntu) or 'yum install jq' (centos/rhel)."; exit 1; }
command -v wg >/dev/null 2>&1 || { echo >&2 "wireguard required, but not installed. install with  'apt install wireguard' (debian/ubuntu) or 'yum install epel-release elrepo-release' and 'yum install kmod-wireguard wireguard-tools' (centos/rhel)."; exit 1; }

#variables - edit if you like - check ProtonVPN API before to get familiar with the naming scheme (SecureCore servers should work, too)
apiurl="https://api.protonvpn.ch/vpn/logicals"
entrycountry="AT"
exitcountry="AT"
vpntier="2"

# util-function to find the correct servers
get_server_data() {
    response=$(curl -s $apiurl)

    if [ -z "$response" ]; then
        echo "ERROR - API not responding or not reachable"
        exit 1
    fi

    echo "$response" | jq -c '.LogicalServers[] | select(.EntryCountry == "'$entrycountry'" and .ExitCountry == "'$exitcountry'" and .Tier == '$vpntier')'
}

parse_server_data() {
    echo "$1" | jq -r '.Name,.Load' | paste -sd " " -
}

# query API and get server with the lowest utilization
server_data=$(get_server_data)
min_load=101
min_load_server=""

for data in $server_data
do
    server=$(parse_server_data "$data")
    load=$(echo "$server" | cut -d' ' -f2)
    if (( $(echo "$load < $min_load" | bc -l) )); then
        min_load=$load
        min_load_server=$(echo "$server" | cut -d' ' -f1)
    fi
done

# check if server got correctly extracted from the API
if [ -z "$min_load_server" ]; then
    echo "ERROR - server could not be extracted from the API"
    exit 1
fi

# use the defined config file for the server and name it correctly + correct permissions
cp /data/split-vpn/wireguard/protonvpn/configs/wg0_${min_load_server}.conf /data/split-vpn/wireguard/protonvpn/configs/wg0.conf && chmod 600 /data/split-vpn/wireguard/protonvpn/configs/wg0.conf

# connect to wireguard vpn and output log
echo "Using server $min_load_server"
wg-quick up /data/split-vpn/wireguard/protonvpn/configs/wg0.conf | tee wireguard.log 2>&1