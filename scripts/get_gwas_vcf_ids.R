# Libraries
library(tidyverse)
library(rtracklayer)
library(plyranges)

# Parse inputs
args <- commandArgs(trailingOnly = TRUE)

gwas_catalog_snp_gr_file <- args[1]
vcf_snp_ids_file <- args[2]
out_file <- args[3]

# Read inputs
gwas_catalog_snp_gr <- readRDS(gwas_catalog_snp_gr_file)
vcf_snp_ids <- read_table(vcf_snp_ids_file)

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
gwas_100genomes_join <- plyranges::join_overlap_left(gwas_catalog_snp_gr, vcf_snp_ids_gr)

gwas_100genomes_join <- gwas_100genomes_join[!is.na(gwas_100genomes_join$ID)]
# Print list to file to use as snpid in plink ld calculation
writeLines(gwas_100genomes_join$ID, out_file)
