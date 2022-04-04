#!/bin/bash  
#SBATCH -J run_enrichBed
#SBATCH --mem=16G
# Inputs

mapped_traits_dir=/hpc/group/vertgenlab/jes157/haqers/data_output/bed/efo_mapped_traits
elements2=/hpc/group/vertgenlab/jes157/haqers/data_raw/bed/HAQER.bed
nogap=/hpc/group/vertgenlab/jes157/haqers/data_raw/bed/hg38.simple.noGap.bed
out=/hpc/group/vertgenlab/jes157/haqers/data_output/tsv/efo_mapped_traits_haqerv1_bedEnrich.tsv

get_enrichments_per_trait.sh $mapped_traits_dir $elements2 $nogap $out