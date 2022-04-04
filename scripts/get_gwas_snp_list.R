# Libraries
library(readr)

## GWAS catalog
gwas_catalog_snp <- readr::read_tsv("./data_raw/gwas_catalog/gwas_catalog_v1.0.2-associations_e105_r2021-12-21.tsv")
gwas_catalog_populations <- readr::read_tsv("./data_raw/gwas_catalog/gwas_catalog-ancestry_r2021-12-21.tsv")

# Note: some associations are filtered out here due to them not having an associated snp.
gwas_catalog_snp <- gwas_catalog_snp[!is.na(gwas_catalog_snp$CHR_POS ),]
gwas_catalog_snp$CHR_POS_NUMERIC <- as.numeric(gwas_catalog_snp$CHR_POS)
gwas_catalog_snp <- gwas_catalog_snp[!is.na(gwas_catalog_snp$CHR_POS_NUMERIC),]

# Filter by population, get SNPs ascertained in European populations 
gwas_catalog_populations_european <- gwas_catalog_populations[gwas_catalog_populations$`BROAD ANCESTRAL CATEGORY`=="European",c("STUDY ACCESSION"),]
gwas_catalog_populations_european <- unique(gwas_catalog_populations_european)
gwas_catalog_snp <- gwas_catalog_snp[gwas_catalog_snp$`STUDY ACCESSION` %in% gwas_catalog_populations_european$`STUDY ACCESSION`,]

# Filter out multi snp records from gwas catalog (those do not have a SNP_ID_CURRENT)
gwas_catalog_snp <- gwas_catalog_snp[!is.na(gwas_catalog_snp$SNP_ID_CURRENT),]

# Some positions have more than one rsid, keep only one  
gwas_catalog_snp <- gwas_catalog_snp[,c("CHR_ID","CHR_POS_NUMERIC","SNPS")]
gwas_catalog_snp <- duplicated(gwas_catalog_snp[,"CHR_ID","CHR_POS_NUMERIC"])

gwas_catalog_snp <- unique(gwas_catalog_snp)

# How to handle the fact that there could be different traits associated to the same snp.
# Get a list of unique ranges:
#  Keep SNPs column for later join with phenotype info
gwas_catalog_snp_gr_uq <- gwas_catalog_snp_gr[,"SNPS"]
gwas_catalog_snp_gr_uq <- unique(gwas_catalog_snp_gr_uq)

