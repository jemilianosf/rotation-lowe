#!/usr/bin/Rscript --vanilla

# Rscript --vanilla get_traitbeds_from_plinkld.R gwas_file.tsv plink.ld out_dir

args <- commandArgs(trailingOnly = TRUE)

gwas_tsv_file <- args[1]
ld_tsv_file <- args[2]
out_dir <- args[3]

# Read mapped traits, split into list and rename list with bedfile names
gwas_snps_trait <- read.table(gwas_tsv_file,header = FALSE)
gwas_snps_trait_list <- split(gwas_snps_trait[,1:2],gwas_snps_trait[,3])
names(gwas_snps_trait_list) <- paste0(out_dir,"/",names(gwas_snps_trait_list),".bed")

# Read ld tsv file 
ld_df_filt <- read.table(ld_tsv_file,header = TRUE)
ld_df_filt$SNP_ID <- paste0("chr",ld_df_filt$CHR_A,":",ld_df_filt$BP_A)

## Loop over each trait, subset the snp coords file, write to bed
for (bed in names(gwas_snps_trait_list)){
  
  gwas_snps <- gwas_snps_trait_list[[bed]]
  # Create ID column to match 
  gwas_snps$SNP_ID <- paste0(gwas_snps$V1,":",gwas_snps$V2)
  
  # Match tables 
  ld_snps <- ld_df_filt[ld_df_filt$SNP_ID %in% gwas_snps$SNP_ID,c("CHR_B","BP_B")]
  
  # We expect some of the traits to not have ld snps 
  if(nrow(ld_snps)==0) next
  
  # Fix chrom names
  ld_snps$CHR_B <- paste0("chr",ld_snps$CHR_B)
  
  # Add table names
  names(ld_snps) <- c("chr","bp_start")
  names(gwas_snps) <- c("chr","bp_start")
  
  # Add gwas snps to ld snps
  ld_snps <- rbind(gwas_snps[,-3],ld_snps)
  
  # Remove duplicates 
  ld_snps <- unique(ld_snps)
  
  # Make bed 
  ld_snps$bp_end <- ld_snps$bp
  ld_snps$bp_start <- ld_snps$bp_start - 1
  
  # Write file
  write.table(ld_snps,file = bed,sep = "\t",row.names = FALSE,col.names = FALSE,quote = FALSE)
}
