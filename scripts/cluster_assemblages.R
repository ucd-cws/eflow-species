## Getting species assemblage by cluster
## Alyssa Obester
## October 4, 2018

library(dplyr)
library(tidyr)


clustering_results <- read_excel("C:/Users/aobester/Desktop/clustering_results_10042018.xls") #load the data

#break up data into 4 regions and then want assemblage list for each cluster within a region




central_valley <- filter(clustering_results, huc_region_group == 'central_valley') 

central_valley <- separate_rows(central_valley, current_assemblage_Flow_Sensitive, sep = ",") %>% #separating all the species in the current assemblage column
  group_by(cluster_name) %>% #then regrouping them by cluster name
  summarise(current_assemblage_Flow_Sensitive = paste0(unique(current_assemblage_Flow_Sensitive), collapse = ", "))

#how to add this back to the original data frame?
#maybe create a new df and do a join based on cluster_name?

central_valley <- rename(central_valley, Cluster_Assemblage = current_assemblage_Flow_Sensitive) #rename this so we can do a join

###############################################################

#repeat the above for the remaining 3 regions

### great basin


great_basin <- filter(clustering_results, huc_region_group == "great_basin")

great_basin <- separate_rows(great_basin, current_assemblage_Flow_Sensitive, sep = ",") %>% #separating all the species in the current assemblage column
  group_by(cluster_name) %>% #then regrouping them by cluster name
  summarise(current_assemblage_Flow_Sensitive = paste0(unique(current_assemblage_Flow_Sensitive), collapse = ", "))

#how to add this back to the original data frame?
#maybe create a new df and do a join based on cluster_name?

great_basin <- rename(great_basin, Cluster_Assemblage = current_assemblage_Flow_Sensitive) #rename this so we can do a join

### north coast

north_coast <- filter(clustering_results, huc_region_group == "north_coast")

north_coast <- separate_rows(north_coast, current_assemblage_Flow_Sensitive, sep = ",") %>% #separating all the species in the current assemblage column
  group_by(cluster_name) %>% #then regrouping them by cluster name
  summarise(current_assemblage_Flow_Sensitive = paste0(unique(current_assemblage_Flow_Sensitive), collapse = ", "))

#how to add this back to the original data frame?
#maybe create a new df and do a join based on cluster_name?

north_coast <- rename(north_coast, Cluster_Assemblage = current_assemblage_Flow_Sensitive) #rename this so we can do a join


### south coast

south_coast <- filter(clustering_results, huc_region_group == "south_coast")

south_coast <- separate_rows(south_coast, current_assemblage_Flow_Sensitive, sep = ",") %>% #separating all the species in the current assemblage column
  group_by(cluster_name) %>% #then regrouping them by cluster name
  summarise(current_assemblage_Flow_Sensitive = paste0(unique(current_assemblage_Flow_Sensitive), collapse = ", "))

#how to add this back to the original data frame?
#maybe create a new df and do a join based on cluster_name?

south_coast <- rename(south_coast, Cluster_Assemblage = current_assemblage_Flow_Sensitive) #rename this so we can do a join


## bind and join!!!

cluster_assemblages <- bind_rows(central_valley, great_basin, north_coast, south_coast)

final_results_cluster_assemblages <- full_join(clustering_results, cluster_assemblages, by = "cluster_name")