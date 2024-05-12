#!/bin/bash
# Author: Basant Karki (basant0x01)
# Tool: Advance Version of dirsearch
# Usage: ./awps.sh -l subdomains.txt

# Default values for parameters
subdomain_file=""

# Parse command line options
while getopts ":l:" opt; do
  case $opt in
    l) subdomain_file="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Check if the subdomain file is provided
if [ -z "$subdomain_file" ]; then
    echo "Error: Please provide the path to the subdomain file using the -l option."
    exit 1
fi

# Check if the file containing subdomains exists
if [ ! -f "$subdomain_file" ]; then
    echo "Error: $subdomain_file not found!"
    exit 1
fi

# Loop through each subdomain in the file and run dirsearch
while read -r subdomain; do
    echo "Scanning $subdomain..."
    dirsearch -u "$subdomain" --max-rate=300 -t 100 --force-recursive -i 200 --random-agent -r --deep-recursive --quiet
    echo "Scan for $subdomain completed."
done < "$subdomain_file"
