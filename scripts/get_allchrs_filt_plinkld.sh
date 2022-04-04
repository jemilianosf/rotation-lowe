#!/usr/bin/env bash

# Check inputs
if [ $# -ne 3 ]; then 
    echo -e "Usage: bash get_allchrs_filt_plinkld.sh plinkld_dir r2_cutoff out_file"
    exit 1
fi

ld_files_dir=$1 
r2_cutoff=$2
out_file=$3

echo -e "CHR_A\tBP_A\tSNP_A\tCHR_B\tBP_B\tSNP_B\tR2" > $out_file

for ld_file in ${ld_files_dir}/*ld;
do
  awk -v cutoff=$r2_cutoff 'NR>1 && $7>cutoff {print $1,$2,$3,$4,$5,$6,$7}' OFS="\t" $ld_file >> $out_file 
done
