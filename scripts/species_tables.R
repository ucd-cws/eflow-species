##create species presence tables for flow-sensitive clustering

library(dplyr)
library(tidyr)
library(splitstackshape)
library(stringr)
library(fuzzySim)


cluster_assemblages_v3 <- read.csv("C:/Users/aobester/Downloads/cluster_assemblages_v3.csv", stringsAsFactors = FALSE)

master_cluster_assemblage <- read.csv("//cws-s1.ou.ad3.ucdavis.edu/projects/environmental_flows/Tier 2/Fish Species Expert Opinion/master_cluster_assemblage.csv")

#separate the regions because we want separate tables for each
cv_assemblage <- select(master_cluster_assemblage, "central_valley_1":"central_valley_4")
gb_assemblage <- select(master_cluster_assemblage, "great_basin_1":"great_basin_3")
nc_assemblage <- select(master_cluster_assemblage, "north_coast_1":"north_coast_6")
sc_assemblage <- select(master_cluster_assemblage, "south_coast_1":"south_coast_3")


#give every cluster and fish species present a unique row, split by commas
cv1 <- cSplit(cv_assemblage, "central_valley_1", ",")
cv2 <- cSplit(cv_assemblage, "central_valley_2", ",")
cv3 <- cSplit(cv_assemblage, "central_valley_3", ",")
cv4 <- cSplit(cv_assemblage, "central_valley_4", ",")

gb1 <- cSplit(gb_assemblage, "great_basin_1", ",")
gb3 <- cSplit(gb_assemblage, "great_basin_3", ",")
gb2 <-cSplit(gb_assemblage, "great_basin_2", ",")

nc1 <- cSplit(nc_assemblage, "north_coast_1", ",")
nc2 <- cSplit(nc_assemblage, "north_coast_2", ",")
nc3 <- cSplit(nc_assemblage, "north_coast_3", ",")
nc4 <- cSplit(nc_assemblage, "north_coast_4", ",")
nc5 <- cSplit(nc_assemblage, "north_coast_5", ",")
nc6 <- cSplit(nc_assemblage, "north_coast_6", ",")

sc1 <- cSplit(sc_assemblage, "south_coast_1", ",")
sc2 <- cSplit(sc_assemblage, "south_coast_2", ",")
sc3 <-cSplit(sc_assemblage, "south_coast_3", ",")

#for a region, separate out each cluster. could have skipped this step but bind doesn't work when trying to combine the clusters from the step above.
cv1_a <- select(cv1, "central_valley_1_01":"central_valley_1_15")
cv2_a <- select(cv2, "central_valley_2_01":"central_valley_2_21")
cv3_a <- select(cv3, "central_valley_3_01":"central_valley_3_17")
cv4_a <- select(cv4, "central_valley_4_01":"central_valley_4_13")


gb1_a <- select(gb1, "great_basin_1_1":"great_basin_1_3")
gb3_a <- select(gb3, "great_basin_3_1":"great_basin_3_8")
gb2_a <- select(gb2, "great_basin_2_1":"great_basin_2_7")

nc1_a <- select(nc1, "north_coast_1_01":"north_coast_1_23")
nc2_a <- select(nc2, "north_coast_2_01":"north_coast_2_12")
nc3_a <- select(nc3, "north_coast_3_01":"north_coast_3_19")
nc4_a <- select(nc4, "north_coast_4_01":"north_coast_4_24")
nc5_a <- select(nc5, "north_coast_5_01":"north_coast_5_21")
nc6_a <- select(nc6, "north_coast_6_01":"north_coast_6_14")

sc1_a <- select(sc1, "south_coast_1_01":"south_coast_1_10")
sc2_a <- select(sc2, "south_coast_2_01":"south_coast_2_14")
sc3_a <- select(sc3, "south_coast_3_1":"south_coast_3_9")





##

all_cv <- bind_rows(cv1_a, cv2_a, cv3_a, cv4_a) #combining all the CV cluster data

all_cv_t <- gather(all_cv, na.rm = TRUE) #transpose and remove NAs
colnames(all_cv_t) <- c("Cluster", "Species") 

all_gb <- bind_rows(gb1_a, gb2_a, gb3_a)
all_gb_t <- gather(all_gb, na.rm = TRUE)
colnames(all_gb_t) <- c("Cluster", "Species")

all_nc <- bind_rows(nc1_a, nc2_a, nc3_a, nc4_a, nc5_a, nc6_a)
all_nc_t <- gather(all_nc, na.rm = TRUE)
colnames(all_nc_t) <- c("Cluster", "Species")

all_sc <- bind_rows(sc1_a, sc2_a, sc3_a)
all_sc_t <- gather(all_sc, na.rm = TRUE)
colnames(all_sc_t) <- c("Cluster", "Species")


##

#get rid of the last three numbers in cluster ID
all_cv_str <- as.data.frame(str_sub(all_cv_t$Cluster, 1, str_length(all_cv_t$Cluster)-3))
combined_cv <- bind_cols(all_cv_str, all_cv_t)
colnames(combined_cv) <- c("Cluster", "Cluster2", "Species")
combined_cv_2 <- select(combined_cv, "Cluster", "Species")


all_gb_str <- as.data.frame(str_sub(all_gb_t$Cluster, 1, str_length(all_gb_t$Cluster)-2))
combined_gb <- bind_cols(all_gb_str, all_gb_t)
colnames(combined_gb) <- c("Cluster", "Cluster2", "Species")
combined_gb_2 <- select(combined_gb, "Cluster", "Species")

all_nc_str <- as.data.frame(str_sub(all_nc_t$Cluster, 1, str_length(all_nc_t$Cluster)-3))
combined_nc <- bind_cols(all_nc_str, all_nc_t)
colnames(combined_nc) <- c("Cluster", "Cluster2", "Species")
combined_nc_2 <- select(combined_nc, "Cluster", "Species")

all_sc_str <- as.data.frame(str_sub(all_sc_t$Cluster, 1, str_length(all_sc_t$Cluster)-3))
combined_sc <- bind_cols(all_sc_str, all_sc_t)
colnames(combined_sc) <- c("Cluster", "Cluster2", "Species")
combined_sc_2 <- select(combined_sc, "Cluster", "Species")


##


#combined_cv_2 <- select(combined_cv, all_cv_str, Species)
#colnames(combined_cv_2) <- c("Cluster", "Species")

#create the species presence tables using splist2presabs function 
sp_table_sc <- splist2presabs(combined_sc_2, sites.col = 1, sp.col = 2)

#transpose this so it's in a more readable format
sp_table_t_sc <- as.data.frame(t(sp_table_sc))

colnames(sp_table_t_sc) <- c("South_Coast_1", "South_Coast_2", "South_Coast_3")

#write to CSV to make it look a little nicer using Excel
write.csv(sp_table_t_sc, file = "species_table_sc.csv")







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







