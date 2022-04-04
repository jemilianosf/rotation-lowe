#!/bin/bash  
#SBATCH -J run_plink
#SBATCH --mem=8G
#SBATCH --array 1-2%1
# Inputs
vcf_list=vcf_list_test.txt
vcf=$(awk -v i=$SLURM_ARRAY_TASK_ID 'NR==i' $vcf_list)
gwas_catalog_snp_gr_file=gwas_catalog_snp_gr_uq.Rds
samples_list=sample_list_unrel_gbr.txt
out_dir=test_out/

# Process inputs
vcf_basename=$(basename $vcf)
vcf_basename=${vcf_basename%.*}

out_prefix=${out_dir}${vcf_basename}

vcf_snp_ids=${out_prefix}.snp_id.txt
gwas_snp_list=${out_prefix}.gwas_snp_ids.txt
out_ld=${out_prefix}.ld_snps

# Get vcf smaller table
gzip -cd $vcf |grep -v '^##' | cut -f1-3 > $vcf_snp_ids

# Get overlaps
module load R/4.1.1-rhel8
Rscript get_gwas_vcf_ids.R $gwas_catalog_snp_gr_file $vcf_snp_ids $gwas_snp_list

# Get LD variants
plink --threads $SLURM_CPUS_ON_NODE --memory 4000 --keep $samples_list --ld-snp-list $gwas_snp_list --vcf $vcf --ld-window-r2 0.2 --ld-window 5000000 --ld-window-kb 1000 --r2 --out $out_ld
