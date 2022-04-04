#!/bin/bash  
#SBATCH -J dl_vcfs
#SBATCH --mem=3G
cd /work/jes157/haqer_gwas_jan22/vcf
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_phased/*vcf.gz