##create species presence tables for flow-sensitive clustering

library(dplyr)
library(tidyr)
library(splitstackshape)
library(stringr)
library(fuzzySim)


cluster_assemblages_v3 <- read.csv("C:/Users/aobester/Downloads/cluster_assemblages_v3.csv", stringsAsFactors = FALSE)


#separate the regions because we want separate tables for each
cv_assemblage <- select(cluster_assemblages_v3, "central_valley_1":"central_valley_5")
gb_assemblage <- select(cluster_assemblages_v3, "great_basin_1", "great_basin_2")
nc_assemblage <- select(cluster_assemblages_v3, "north_coast_2":"north_coast_7")
sc_assemblage <- select(cluster_assemblages_v3, "south_coast_1":"south_coast_4")


#give every cluster and fish species present a unique row, split by commas
cv1 <- cSplit(cv_assemblage, "central_valley_1", ",")
cv2 <- cSplit(cv_assemblage, "central_valley_2", ",")
cv3 <- cSplit(cv_assemblage, "central_valley_3", ",")
cv4 <- cSplit(cv_assemblage, "central_valley_5", ",")

#for a region, separate out each cluster. could have skipped this step by bind doesn't work when trying to combine the clusters from the step above.
cv1_a <- select(cv1, "central_valley_1_01":"central_valley_1_23")
cv2_a <- select(cv2, "central_valley_2_01":"central_valley_2_36")
cv3_a <- select(cv3, "central_valley_3_01":"central_valley_3_17")
cv4_a <- select(cv4, "central_valley_5_01":"central_valley_5_33")

all_cv <- bind_rows(cv1_a, cv2_a, cv3_a, cv4_a) #combining all the CV cluster data

all_cv_t <- gather(all_cv, na.rm = TRUE) #transpose and remove NAs
colnames(all_cv_t) <- c("Cluster", "Species") 

#get rid of the last three numbers in cluster ID
all_cv_str <- as.data.frame(str_sub(all_cv_t$Cluster, 1, str_length(all_cv_t$Cluster)-3))

combined_cv <- bind_cols(all_cv_str, all_cv_t)
combined_cv_2 <- select(combined_cv, all_cv_str, Species)
colnames(combined_cv_2) <- c("Cluster", "Species")

#create the species presence tables using splist2presabs function 
sp_table <- splist2presabs(combined_cv_2, sites.col = 1, sp.col = 2)

#transpose this so it's in a more readable format
sp_table_t <- as.data.frame(t(sp_table))

colnames(sp_table_t) <- c("Central_Valley_1", "Central_Valley_2", "Central_Valley_3", "Central_Valley_5")

#write to CSV to make it look a little nicer using Excel
write.csv(sp_table_2, file = "cluster_table.csv")



#### FUNCTION TO CREATE SPECIES TABLES
#from: https://modtools.wordpress.com/2013/04/30/splist2presabs/

splist2presabs <- function(data, sites.col, sp.col, keep.n = FALSE) {
  # version 1.1 (7 May 2013)
  # data: a matrix or data frame with your localities and species (each in a different column)
  # sites.col: the name or index number of the column containing the localities
  # sp.col: the name or index number of the column containing the species names or codes
  # keep.n: logical, whether to get in the resulting table the number of times each species appears in each locality; if false (the default), only the presence (1) or absence (0) are recorded
  
  stopifnot(
    length(sites.col) == 1,
    length(sp.col) == 1,
    sites.col != sp.col,
    sites.col %in% 1 : ncol(data) | sites.col %in% names(data),
    sp.col %in% 1 : ncol(data) | sp.col %in% names(data),
    is.logical(keep.n)
  )
  
  presabs <- table(data[ , c(sites.col, sp.col)])
  presabs <- as.data.frame(unclass(presabs))
  if (!keep.n)  presabs[presabs > 1] <- 1
  presabs <- data.frame(row.names(presabs), presabs)
  names(presabs)[1] <- names(subset(data, select = sites.col))
  rownames(presabs) <- NULL
  return(presabs)
}  # end splist2presabs function

####







