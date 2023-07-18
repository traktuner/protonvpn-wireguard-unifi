# Whats that?
This script solves an annoying problem I had.
Wireguard configs from ProtonVPN are only available per-server and not per-country (as it was the case with OpenVPN configs).
So I made this script which queries the ProtonVPN API, extracts the best server and then uses the correct config file.
Designed especially for the Unifi Dream Machine Pro, but should also work for all UnifiOS devices (UDM, UDM Pro, UDM SE, UXG Pro, UDR,...)

## Prerequisites

[On-Boot script](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)

[Split-VPN](https://github.com/peacey/split-vpn)


## How To
1. Configure the On-Boot Script and Split-VPN (Wireguard section) accordingly.
2. Navigate to https://protonvpn.com and head over to the download section.
3. Download all the necessary country-specific wireguard config files and edit them according the Split-VPN readme
4. Name all config files wg0_[country]#[servernumber].conf (wg0 is the interface name) and place them in a "configs" subdirectory
5. The script is designed to work for all ProtonVPN PLUS servers in Austria (AT) - you can adapt the script to your needs

## Issues?
Did this solve a problem for you? That's awesome! I'm happy. Find me on [Mastodon](https://mastodon.social/@traktuner) and let me know :)

If you want me to help you with something: No. I wrote this to save myself time, and because it was fun to figure out an annoying problem. 
Go and read [this](https://snarky.ca/the-social-contract-of-open-source/) instead ;-)