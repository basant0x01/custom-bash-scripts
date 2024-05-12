#!/bin/bash
# Author: Basant Karki (basant0x01)
# Tool: Advance Subdomain Scanner
# Usage: ./sublyzer.sh -l subdomains.txt

# ANSI color codes for better terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

function cleanup_old_files(){
    rm -fr *.old.txt
    rm -fr all_non_resolved_subdomains.txt
}

function scan_with_subfinder(){
    echo -e "${CYAN}Scanning with Subfinder for $1...${NC}"
    subfinder -d "$1" -o subfinder_subdomains.txt >/dev/null 2>&1
    echo -e "${GREEN}Subfinder scan complete for $1${NC}"
}

function scan_with_sublist3r(){
    echo -e "${CYAN}Scanning with Sublist3r for $1...${NC}"
    sublist3r -d "$1" -o sublist3r_subdomains.txt >/dev/null 2>&1
    echo -e "${GREEN}Sublist3r scan complete for $1${NC}"
}

function scan_with_findomain(){
    echo -e "${CYAN}Scanning with Findomain for $1...${NC}"
    findomain -t "$1" -q -u findomain_subdomains.txt >/dev/null 2>&1
    echo -e "${GREEN}Findomain scan complete for $1${NC}"
}

function generate_alt_subdomains(){
    echo -e "${CYAN}Generating alternative subdomains for $1...${NC}"
    if [ -f "words.txt" ]; then
        echo -e "${CYAN}Using existing words.txt file...${NC}"
    else
        echo -e "${CYAN}Downloading words.txt file...${NC}"
        curl -sS https://raw.githubusercontent.com/infosec-au/altdns/master/words.txt -o words.txt
    fi
    altdns -i "$1" -o alt_subdomains.txt -w words.txt >/dev/null 2>&1
    echo -e "${GREEN}Alternative subdomains generated for $1${NC}"
}

function combine_subdomains(){
    echo -e "${YELLOW}Combining subdomains...${NC}"
    cat subfinder_subdomains.txt sublist3r_subdomains.txt findomain_subdomains.txt alt_subdomains.txt | sort -u > all_non_resolved_subdomains.txt
    rm subfinder_subdomains.txt sublist3r_subdomains.txt findomain_subdomains.txt alt_subdomains.txt
    echo -e "${GREEN}Subdomains combined into all_non_resolved_subdomains.txt${NC}"
}

function resolve_live_subdomains(){
    echo -e "${CYAN}Resolving live subdomains using httpx...${NC}"
    httpx -l all_non_resolved_subdomains.txt -o live_subdomains.txt >/dev/null 2>&1
    echo -e "${GREEN}Live subdomains resolved and saved to live_subdomains.txt${NC}"
}

function main(){
    cleanup_old_files

    while getopts ":l:" opt; do
        case ${opt} in
            l )
                domain_list=$OPTARG
                ;;
            \? )
                echo "Usage: $0 -l subdomains.txt"
                exit 1
                ;;
            : )
                echo "Invalid option: $OPTARG requires an argument" 1>&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1))

    if [ -z "$domain_list" ]; then
        echo "Usage: $0 -l subdomains.txt"
        exit 1
    fi

    while IFS= read -r domain; do
        scan_with_subfinder "$domain" &
        scan_with_sublist3r "$domain" &
        scan_with_findomain "$domain" &
        generate_alt_subdomains "$domain" &
        wait
    done < "$domain_list"

    combine_subdomains
    resolve_live_subdomains
    cleanup_old_files
}

main "$@"
