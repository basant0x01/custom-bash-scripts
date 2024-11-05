#!/bin/bash

# Ask user for the length of OTP pin
echo "Please enter the length of the OTP pin:"
read length

# Validate the input
if ! [[ "$length" =~ ^[0-9]+$ ]] || [ "$length" -le 0 ]; then
    echo "Invalid input. Please enter a positive integer."
    exit 1
fi

# Generate the total number of OTPs
total_pins=$(( 10 ** length ))

# Set output file name based on OTP length
output_file="${length}_digit_pins.txt"

# Generate all possible OTP pins and save them to the output file
echo "Generating all possible OTP pins of length $length and saving to $output_file..."

> "$output_file"  # Clear the file if it exists

# Generate all OTPs, with padding to match the required length
for ((i=0; i<total_pins; i++)); do
    printf "%0${length}d\n" $i >> "$output_file"
done

# Output success message
echo "All possible OTP pins generated and saved to $output_file."

# Optionally, display the first few generated pins
head -n 10 "$output_file"
