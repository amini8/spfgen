#!/bin/bash

# Function to generate the SPF record
generate_spf_record() {
    # Start with the v=spf1 tag
    spf_record="v=spf1 "

    # Add MX record mechanism if selected
    if [[ "$mx" == "Yes" ]]; then
        spf_record+="mx "
    fi

    # Add A record mechanism if selected
    if [[ "$a" == "Yes" ]]; then
        spf_record+="a "
    fi

    # Add IPv4 CIDR ranges if provided
    if [[ -n "$ipv4" ]]; then
        spf_record+="ip4:$ipv4 "
    fi

    # Add IPv6 CIDR ranges if provided
    if [[ -n "$ipv6" ]]; then
        spf_record+="ip6:$ipv6 "
    fi

    # Add included domains if provided
    if [[ -n "$include" ]]; then
        spf_record+="include:$include "
    fi

    # Add policy if provided
    if [[ -n "$policy" ]]; then
        spf_record+="${policy^^} "
    fi

    # Append the "all" mechanism as the default
    spf_record+="all"

    # Add the SPF record delimiter
    spf_record+="\n"

    echo "$spf_record"
}

# Function to check if the domain already has an SPF record
has_spf_record() {
    # Query DNS for TXT records for the domain
    txt_records=$(dig +short TXT "$1" | tr -d '"')

    # Check if any TXT record starts with "v=spf1"
    for txt_record in $txt_records; do
        if [[ "$txt_record" == v=spf1* ]]; then
            return 0
        fi
    done

    return 1
}

# Prompt user for domain
read -p "Enter the domain: " domain

# Check if domain already has an SPF record
if has_spf_record "$domain"; then
    echo "This domain already has an SPF record."
    exit
fi

# Function to check if the domain already has an SPF record
# has_spf_record() {
    # Query DNS for TXT records for the domain
    # txt_records=$(nslookup -q=TXT "$1" | grep -oE 'v=spf1.*')

    # Check if any TXT record starts with "v=spf1"
    # if [[ "$txt_records" == v=spf1* ]]; then
        # return 0
    # fi

    # return 1
# }


# Prompt user for configuration options
read -p "Include MX record mechanism? (Yes/No): " mx
read -p "Include A record mechanism? (Yes/No): " a
read -p "Enter IPv4 CIDR range(s) (comma-separated, empty for none): " ipv4
read -p "Enter IPv6 CIDR range(s) (comma-separated, empty for none): " ipv6
read -p "Enter included domain(s) (comma-separated, empty for none): " include
read -p "Enter policy (empty for none): " policy

# Generate SPF record
spf_record=$(generate_spf_record)
echo "$spf_record"
