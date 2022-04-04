#!/bin/bash  
#SBATCH -J run_enrichBed
#SBATCH --mem=16G
#SBATCH -a 1-2
# Inputs

inputs_file=/hpc/group/vertgenlab/jes157/execution_scripts/input_test.txt

method=$(awk -v i=$SLURM_ARRAY_TASK_ID 'NR==i{print $1}' $inputs_file)
mapped_traits_dir=$(awk -v i=$SLURM_ARRAY_TASK_ID 'NR==i{print $2}' $inputs_file)
elements2=$(awk -v i=$SLURM_ARRAY_TASK_ID 'NR==i{print $3}' $inputs_file)
nogap=$(awk -v i=$SLURM_ARRAY_TASK_ID 'NR==i{print $4}' $inputs_file)
out=$(awk -v i=$SLURM_ARRAY_TASK_ID 'NR==i{print $5}' $inputs_file)

get_enrichments_per_trait.sh $method $mapped_traits_dir $elements2 $nogap $out