#!/usr/bin/env bash

# Check inputs
if [ $# -ne 4 ]; then 
    echo -e "Usage: bash get_bed_from_plinkld.sh"
    exit 1
fi

awk ''