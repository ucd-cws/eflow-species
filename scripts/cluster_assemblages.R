## Getting species assemblage by cluster
## Alyssa Obester
## October 4, 2018

library(dplyr)
library(tidyr)


clustering_data <- read.csv("data/web/fancy_map_data_base.csv") #load the data

#break up data into 4 regions and then want assemblage list for each cluster within a region



get_cluster_assemblages <- function(clustering_results, region_group){
  filtered <- filter(clustering_results, huc_region_group == region_group) 
  
  separated <- separate_rows(filtered, current_assemblage_Flow_Sensitive, sep = ",") %>% #separating all the species in the current assemblage column
    group_by(cluster_name, current_assemblage_Flow_Sensitive) %>% #then regrouping them by cluster name
    summarise(cluster_assemblage = paste0(current_assemblage_Flow_Sensitive, collapse=", "))

  summarised <- separated %>% group_by(cluster_name) %>%
          summarise(cluster_assemblage2 = paste0(current_assemblage_Flow_Sensitive, collapse = ", "))

  
  #how to add this back to the original data frame?
  #maybe create a new df and do a join based on cluster_name?
  
  return(summarised) #rename this so we can do a join
}

#reshape_table <- function(clustering_data, region_group){
#  filtered <- filter(clustering_results, huc_region_group == region_group)
#  separated <- separate_rows(filtered, current_assemblage_Flow_Sensitive, sep = ",") %>% #separating all the species in the current assemblage column
#    group_by(cluster_name) %>% #then regrouping them by cluster name
#}

central_valley <- get_cluster_assemblages(clustering_results = clustering_data, region_group = "central_valley")
great_basin <- get_cluster_assemblages(clustering_results = clustering_data, region_group = "great_basin")
south_coast <- get_cluster_assemblages(clustering_results = clustering_data, region_group = "south_coast")
north_coast <- get_cluster_assemblages(clustering_results = clustering_data, region_group = "north_coast")


## bind and join!!!

cluster_assemblages <- bind_rows(central_valley, great_basin, north_coast, south_coast)

final_results_cluster_assemblages <- full_join(clustering_data, cluster_assemblages, by = "cluster_name")
