#!/bin/bash  
#SBATCH -J run_plink
#SBATCH --mem=8G
# Inputs

plinkld_dir=/work/jes157/haqer_gwas_jan22/gwas_ld_variants_27jan22
r2_cutoff=0.7
out_file=/hpc/group/vertgenlab/jes157/haqers/data_output/plink/gwas_ld_variants_27jan22_7r2.ld

get_allchrs_filt_plinkld.sh $plinkld_dir $r2_cutoff $r2_cutoff


