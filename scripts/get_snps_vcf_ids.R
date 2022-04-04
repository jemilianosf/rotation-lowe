# Libraries
library(tidyverse)
library(rtracklayer)
library(plyranges)

# Parse inputs
args <- commandArgs(trailingOnly = TRUE)

snps_file <- args[1]
vcf_snp_ids_file <- args[2]
out_file <- args[3]

# Read inputs
snps <- read_table(snps_file)
vcf_snp_ids <- read_table(vcf_snp_ids_file)

# Make GRanges
colnames(snps) <- c("chr","pos")
snps_gr <- makeGRangesFromDataFrame(snps,
                                    seqnames.field = "chr",
                                    start.field = "pos",
                                    end.field = "pos",
                                    keep.extra.columns = F)

vcf_snp_ids_gr <- makeGRangesFromDataFrame(vcf_snp_ids,
                                           seqnames.field = "#CHROM",
                                           start.field = "POS",
                                           end.field = "POS", 
                                           keep.extra.columns = T)

seqlevels(vcf_snp_ids_gr) <- str_remove(seqlevels(vcf_snp_ids_gr),"chr")

#Some variants in 1000 genomes VCF are duplicated
vcf_snp_ids_gr <- unique(vcf_snp_ids_gr)

# Get overlaping variants from GWAS catalog in the vcf and get a list of variant ids
# Join overlapping ranges 
snps_100genomes_join <- plyranges::join_overlap_left(snps_gr, vcf_snp_ids_gr)

snps_100genomes_join <- snps_100genomes_join[!is.na(snps_100genomes_join$ID)]
# Print list to file to use as snpid in plink ld calculation
writeLines(snps_100genomes_join$ID, out_file)