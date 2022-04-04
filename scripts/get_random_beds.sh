for seed in $(seq 1 1000);
do
  simulateBed -L 891 -N 1753 -setSeed $seed ../data_raw/bed/hg38.simple.noGap.bed ../data_output/bed/random_beds/randbed_${seed}.bed
done