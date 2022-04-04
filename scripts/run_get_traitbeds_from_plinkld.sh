#!/bin/bash  
#SBATCH -J run_plink
#SBATCH --mem=16G
# Inputs

module load R/4.1.1-rhel8

gwas_file=/hpc/group/vertgenlab/jes157/haqers/data_clean/gwas_catalog/gwas_snps_trait.tsv
plink_ld=/hpc/group/vertgenlab/jes157/haqers/data_output/plink/gwas_ld_variants_27jan22_7r2.ld
out_dir=/hpc/group/vertgenlab/jes157/haqers/data_output/bed/efo_mapped_traits

Rscript --vanilla get_traitbeds_from_plinkld.R $gwas_file $plink_ld $out_dir