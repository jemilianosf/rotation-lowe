# Exploration of EFO terms 
library(ontologyIndex)

haqers_per_pheno_counts <- read_tsv("../data_output/tsv/mapped_trait_haqers_pval_1000.tsv")
efo <- get_ontology("../data_raw/obo/efo.obo")
haqers_per_pheno_counts$mapped_trait

# Get mapped trait efo IDs
mapped_trait_efo_ids <- efo$name[efo$name %in% haqers_per_pheno_counts$mapped_trait]

# Get ancestors for each mapped trait
mapped_trait_efo_ancestors <- map(names(mapped_trait_efo_ids), get_term_property,ontology=efo, property="ancestors", as_names=TRUE)
names(mapped_trait_efo_ancestors) <- mapped_trait_efo_ids

# Get mapped traits with "disease" as an ancestor
disease_efo_id <- efo$name[efo$name %in% "disease"]

any(mapped_trait_efo_ancestors$`chronic lymphocytic leukemia` %in% disease_efo_id)

mapped_trait_efo_ancestors_disease <- map_lgl(mapped_trait_efo_ancestors, function(x) { 
  return(any(x %in% disease_efo_id))
})
summary(mapped_trait_efo_ancestors_disease)
