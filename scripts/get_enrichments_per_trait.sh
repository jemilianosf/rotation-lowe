#!/usr/bin/env bash

# Check inputs
if [ $# -ne 5 ]; then 
    echo -e "Usage: bash get_enrichments_per_trait.sh method mapped_traits_dir elements2.bed noGap.bed"
    exit 1
fi

# Assign inputs
method=$1
mapped_traits_dir=$2
elements2=$3
nogap=$4
out=$5

# Header
echo -e "#Method\tFilename1\tFilename2\tLenElements1\tLenElements2\tOverlapCount\tDebugCheck\tExpectedOverlap\tEnrichment\tpValue" > $out

# Calculate enrichments
for elements1 in $(ls ${mapped_traits_dir});
do
  tmpfile=$(mktemp --tmpdir=/work/jes157/tmp)
  bedEnrichments $method ${mapped_traits_dir}/$elements1 $elements2 $nogap $tmpfile
  grep -v '^#' $tmpfile >> $out
done

