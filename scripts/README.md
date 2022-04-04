# Inputs

## External files

### GWAS Catalog
- Associations table: gwas_associations.tsv
https://www.ebi.ac.uk/gwas/api/search/downloads/studies_new

- Ancestries table: gwas_ancestry.tsv
https://www.ebi.ac.uk/gwas/api/search/downloads/ancestries_new

### 1000 genomes

- chrN_genomes1000.vcf: Phased, filtered, high coverage variants VCF per chromosome
ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_phased/*vcf.gz

- integrated_call_samples_v3.20130502.ALL.panel: Table of original unrelated individuals sample information
http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v3.20130502.ALL.panel

### Experimental Factor Ontology
- efo.obo: experimental factor ontology file
http://www.ebi.ac.uk/efo/efo.obo

## Lab files
- haqers.bed
- NoGap.bed

# Outputs



# 1. Get LD variants from GWAS Catalog and 1000 genomes 

## Step 1.1: Filter GWAS catalog SNPs
### Script:
get_gwas_snp_list.R
### Description:
Filters the GWAS catalog associations table
- Keep SNPs ascertained in European populations
- Remove associations that do not report a SNP
- Remove associations that report more than one SNP
### Inputs:
- gwas_associations.tsv: GWAS catalog associations table 
- gwas_ancestries.tsv: GWAS catalog ancestries table
### Outputs:
- gwas_associations_filt_unique.tsv, fields: chr, start, rsid

## Step 1.2: Get list of sample ids from VCFs to use in plink
### Script: filter_samples.awk
### Description:
Get list of European (GBR) unrelated samples in the 1000 genomes to use in plink downstream
### Inputs:
- genomes1000_samples_info.tsv
### Outputs:
- sample_list_unrel_gbr.txt, fields: family_id, sample_id

## Step 1.3: Convert GWAS SNP ids to 1000 Genomes VCF snp ids
### Script: get_gwas_vcf_ids.R
### Description:
- Exact match of genomic coordinates (chr, pos) in GWAS catalog and 1000 genomes 
- This will filter out GWAS SNPs not in the 1000 genomes
### Inputs:
- chrN_genomes1000.vcf
- gwas_associations_filt_unique.tsv
### Outputs:
- gwas_vcf_ids.txt, fields: id 

## Step 1.4: Get variants in LD
### Script: plinkLD.sh
### Description:
- Wrapper for plink --r2 
- Note: this is ran per chromosome
### Inputs:
- chrN_genomes1000.vcf
- gwas_vcf_ids.txt
- sample_list_unrel_gbr.txt
### Outputs:
- gwas_chrN.ld

## Step 1.5: Get filtered whole genome plink ld table
### Script: get_allchrs_filt_plinkld.sh
### Description: 
- Filter ld outputs with R2 > 0.7
- Concatenate all chromosomes
### Inputs:
- gwas_chrN.ld (one file per chromosome)
### Outputs:
- gwas_all_chrs.ld, fields: chr_a, pos_a, id_a, chr_b, pos_b, id_b, r2

# 2a. Make beds of variants associated with mapped EFO traits 

## Step 2.1: Get trait_id, trait_name mapping table
### Script: get_gwas_snps_trait.R
### Description:
- Filter GWAS associations table to get a trait_id, trait_name table  
### Inputs:
- gwas_associations.tsv
### Outputs:
- gwas_snps_trait.tsv, fields: chr, pos, trait_id, trait_name 

## Step 2.2: Convert plink output to bed by mapped trait
### Script: get_traitbeds_from_plinkld.R
### Description:
- For each trait generates a bed file that contains all variants associated with that trait
### Inputs:
- gwas_all_chrs.ld, Plink ld output, fields: SNP_A, CHR_A,BP_A,SNP_B, CHR_B, BP_B, R2
- gwas_snps_trait.tsv, Table of traits, fields: CHR_A, BP_A, TRAIT_ID
### Outputs:
traits_dir/*.bed, A directory with a bed per trait 

# 2b. Make beds of variants associated with higher level EFO terms 

## Step 2.3: Get table of traits and trait ids
### Script: get_map_efo_traits.R
### Description:
- Selects two columns from the associations file containing the ids and names for efo traits.
- Separates multi-trait lines into different lines.
- Keeps unique lines.
### Inputs:
- gwas_associations.tsv
### Outputs:
- efo_traits.tsv, fields: trait_id, trait_name

## Step 2.4: Map trait_id to a term in a higher level of the experimental factor ontology.
### Script: get_efo_trait2higher.R
### Description:
- Maps trait_ids to a term in a higher level of the hierarchy.
- Keep only traits that are descendants of "efo category" (e.g. disease).
- Map traits to "n children" terms of "efo category". If n children = 1, will return terms 1 level below "efo cateogry".
### Inputs:
- efo category 
- n children (number of levels below "efo category")
- efo.obo
efo_traits.tsv
### Outputs:
- efo_traits_higher_level.tsv, fields: trait_name, trait_id, higher_term_name, higher_term_id

## Step 2.5: Annotate gwas snps with higher term ids
### Script: get_gwas_snps_efo.R
### Description:
- Joins table of snp - trait and trait - higher term to get snp - higher term
### Inputs:
- gwas_snps_trait.tsv
- efo_traits_higher_level.tsv
### Outputs:
- gwas_snps_efo_higher.tsv, fields: start, pos, higher_term

# 3. Calculate overlap enrichments 

## Step 3.1: Wrapper for bedEnrichments
### Script: get_enrichments_per_trait.sh
### Description:
- Runs gonomics:bedEnrichments exact for every bed under traits_dir/
- Cats all results into a single file
### Inputs:
- traits_dir
- haqers.bed
- NoGap.bed
### Outputs:
- efo_mapped_traits_haqerv1_bedEnrich_exact.tsv

# 4. Plot overlap enrichments and  multiple test correction

## Step 4.1: Correct for multiple testing and make plots
### Script: get_enrichment_plots.R
### Description:
- Maps EFO ids to EFO trait names
- Adjusts p values with p.adjust(method = "fdr")
- p adjusted cutoff of < 0.05
- Makes plots
### Inputs:
- efo_mapped_traits_haqer_bedEnrich_exact/*.tsv
- efo_traits_higher_level.tsv
### Outputs:
- efo_mapped_traits_haqer_bedEnrich_exact.pdf 
- efo_mapped_traits_haqer_bedEnrich_exact_padj.tsv, fields: bedEnrichments output plus: padjust, trait_name 
