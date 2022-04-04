# Get haqer overlaps script

# Libraries
library(tidyverse)
library(rtracklayer)
library(plyranges)

# Functions

# Join a GRanges of haqers, with metadata containing the gwas and ld snps they overlap, and a gwas phenotype info table, join by coordinate of gwas snp
get_overlaps_phenos <- function(haqers_overlaps, gwas_snp_info) {
  haqers_overlaps <- as.data.frame(haqers_overlaps)
  haqers_overlaps$CHR_A <- as.character(haqers_overlaps$CHR_A)
  haqers_overlaps$BP_A <- as.numeric(haqers_overlaps$BP_A)
  
  haqers_overlaps_pheno <- left_join(haqers_overlaps,gwas_snp_info, by = c("CHR_A"="CHR_ID", "BP_A"="CHR_POS"))
  return(haqers_overlaps_pheno)
}
# File variables
ld_files_path <- "../data_output/plink/gwas_ld_snps_27jan22/"
gwas_catalog_snp_path <- "../data_raw/gwas_catalog/gwas_catalog_v1.0.2-associations_e105_r2021-12-21.tsv"

# Read in all LD files
ld_files_list <- list.files(ld_files_path,pattern = "ld_snps.ld",full.names = TRUE)
out_ld_df <- do.call(rbind, lapply(ld_files_list, read_table))
gc()

# Filter by R2 > 0.7
# Filtering for LD with R2 of at least 0.7
out_ld_df <- dplyr::filter(out_ld_df,R2 >= 0.7)
gc()

# specific traits
# Read gwas catalog information
gwas_catalog_snp <- read_tsv(gwas_catalog_snp_path)
# Change types of some variables to make them compatible with later table join
gwas_catalog_snp$CHR_POS <- as.numeric(gwas_catalog_snp$CHR_POS)
gwas_catalog_snp <- gwas_catalog_snp[!is.na(gwas_catalog_snp$CHR_POS),]

#Overlap gwas phenotype info with haqers that overlap a gwas snp, join by coordinate of gwas snp
# Join random haqers-snps granges with gwas phenotype info 
gwas_ld_snp_random_pheno_df_list <- lapply(gwas_ld_snp_random_gr_list,get_overlaps_phenos,gwas_snp_info = gwas_catalog_snp)
haqers_olap_pheno_df <- get_overlaps_phenos(gwas_ld_snp_haqers_gr,gwas_catalog_snp)

# Output haqers overlap df
saveRDS(haqers_olap_pheno_df,"../data_output/rds/haqers_olap_pheno_df.Rds")
# Output random overlap list
saveRDS(gwas_ld_snp_random_pheno_df_list, "../data_output/rds/gwas_ld_snp_random_pheno_df_list.Rds")
