library(sf)
library(maps)
#library(devtools)
#devtools::install_github("tidyverse/ggplot2") # need latest version of ggplot2 in order to use geom_sf
library(ggplot2)
library(rgdal)
library(tidyr)
library(dplyr)

group_palette <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a')

huc12_eflow_percents <- read.csv("data/HUC12s_eflow_percent.csv", stringsAsFactors = FALSE)

species_maps <-function(groupname, title){
  suffix<-"_R50_Std_AM_Euc"
  huc_data <- sf::st_as_sf(rgdal::readOGR(paste("data/clustering/huc_groupings/",groupname,"_flowsensitive.gpkg", sep=""),groupname, stringsAsFactors=FALSE))
  # now, we need to convert the attributes we're using for groupings into a single column so that GGPlot can do our mapping for us with facets
  huc_data_mapping <- huc_data %>% gather(key=model_run, value=grouping, paste(groupname,"_KM2",suffix, sep=""),paste(groupname,"_KM3",suffix, sep=""),paste(groupname,"_KM4",suffix, sep=""),paste(groupname,"_KM5",suffix, sep=""),paste(groupname,"_KM6",suffix, sep=""),paste(groupname,"_KM7",suffix, sep=""),paste(groupname,"_KM8",suffix, sep=""),paste(groupname,"_KM9",suffix, sep=""))
  
  plot <- ggplot() + 
    geom_sf(huc_data_mapping, lwd = 5, mapping=aes(fill=grouping), color=NA)+ 
    scale_fill_manual(values=group_palette, limits=c(1,2,3,4,5,6,7,8,9)) +
    ggtitle(paste(title," Species Groupings", sep="")) +
    facet_wrap("model_run")+
    theme_bw()+
    theme(panel.grid.major = element_line(colour = 'transparent'))+
    theme(strip.background = element_blank(), # facet theme control
          strip.placement = "outside", 
          axis.line.x = element_line(color="black", size = 1),
          axis.line.y = element_line(color="black", size = 1),
          plot.title = element_text(hjust = 0.5))
  return(list("region_map"=plot,"species_data"=huc_data))
  
}


species_lists_by_group_dfs <- function (data_frame, group_name, groups=c(2,3,4,5,6,7,8,9), counts=FALSE){
  # data.frame version of the code
  
  st_geometry(data_frame) <- NULL # drop the SF geometry info
  
  suffix<-"_R50_Std_AM_Euc"
  remove_fields <- c("OBJECTID", "hucs_filtered_HUC_8", "hucs_filtered_HUC_10", "hucs_filtered_HUC_12", "hucs_filtered_ACRES", "hucs_filtered_NCONTRB_A", "hucs_filtered_HU_10_GNIS", "hucs_filtered_HU_12_GNIS", "hucs_filtered_HU_10_DS", "hucs_filtered_HU_10_NAME", "hucs_filtered_HU_10_MOD", "hucs_filtered_HU_10_TYPE", "hucs_filtered_HU_12_DS", "hucs_filtered_HU_12_NAME", "hucs_filtered_HU_12_MOD", "hucs_filtered_HU_12_TYPE", "hucs_filtered_STATES", "hucs_filtered_CVA_NAME", "hucs_filtered_huc_id", "Flow_Sensitive_current_OBJECTID", "Flow_Sensitive_current_HUC_12", "hucs_filtered_META_ID", "Shape_Length", "Shape_Area", "huc4","huc_region_group",paste("KM_6",suffix, sep=""),paste("KM_5",suffix, sep=""),paste("KM_8",suffix, sep=""),paste("KM_10",suffix, sep=""),paste("KM_12",suffix, sep=""),paste("KM_14",suffix, sep=""))
  
  data_of_interest <- select(data_frame, -one_of(remove_fields))  # filters to just the current group and removes extra fields
  
  current_field_names <-names(data_of_interest) # get the current column names
  new_field_names <- gsub("Flow_Sensitive_current_", "", current_field_names)  # replace the prefix on the fields
  
  colnames(data_of_interest) <- new_field_names
  
  # general approach we'd want here is to make vectors of the species in each group, then add to a list
  # then extend all lists to be the same length, then cbind them all to a single df and print the df
  all_groupings = list()
  group_dominance_data = data.frame(number_clusters=numeric(), percent_dominant=numeric(), dominant_class=character())  # set it to NA to start - a function will create a data frame from it
  for(grouping in groups){
    output_list = list()  # make an empty output list
    field_name <- paste(group_name,"_KM",grouping,suffix, sep="")
    for(group in seq(1,grouping)){ # for each subgroup in this grouping
      records_in_group <- data_of_interest %>% dplyr::filter_(paste(field_name, "==", as.character(group)))  # filters to just the current group
      
      records_in_group <- records_in_group[, -grep(".+KM.+", colnames(records_in_group))]  # drop columns for groupings
      gathered_data <- as.data.frame(records_in_group) %>% tidyr::gather(key="species", value="presence")
      found_species <- gathered_data %>% dplyr::filter(presence==1) %>% distinct(species)
      g_title <- paste("group_", group, sep="")
      #colnames(found_species) <- g_title  # assign it so that the data frame field has the right name before we merge it
      #found_species <- sort(found_species, na.last=TRUE)
      output_list[[g_title]] = found_species$species  # add the group to the output list  
      
    }
    output_list <- lapply(output_list, `length<-`, max(lengths(output_list)))  # Make all of the vectors in the list the same length
    
    group_dominance_data <- get_cluster_dominance_data(data_frame, field_name, grouping, group_dominance_data, counts=counts)  # pass in the whole DF with the extra fields - we need the HUC 12 field
    
    all_groupings[[grouping]] <- as.data.frame(output_list)
  }
  
  return(list(groupings=all_groupings, dominance_data=group_dominance_data))
}

get_dominant_stream_class_by_hucs <- function(group_records, eflow_data=huc12_eflow_percents, counts=FALSE){
  ## Given a set of records from a cluster, determines the dominant stream flow class in that cluster
  ## and the proportion of it that is the dominant class
  ## If counts is TRUE, then instead of proportion, it outputs the count as the "proportion_dominant", but
  ## it will still include the dominant class in the list output for symbolization
  
  eflow_records <- eflow_data %>% filter(HUC12 %in% group_records$hucs_filtered_HUC_12)
  eflow_sums <- eflow_records %>% group_by(eflow_type) %>% summarise(group_sum = sum(eflow_length, na.rm=TRUE))
  max_record = which.max(eflow_sums$group_sum)
  proportion_dominant = eflow_sums[max_record,]$group_sum / sum(eflow_sums$group_sum)
  if(counts==TRUE){
    output_value = length(eflow_sums)
  }else{
    output_value = proportion_dominant
  }
  return(list(class=eflow_sums[max_record,]$eflow_type, result_value=output_value))
}

add_record_to_df <- function(original_df, num_groups, percent, dominant_class){
  ## This record will keep adding data to the end of the data frame about the dominance data
  if(length(percent) == 0){  # in some cases, we get an effective null, but it's numeric(0) - we have to test the length of it to get whether or not it's this value
    return(original_df)
  }
  new_group_data = data.frame(number_clusters=num_groups, percent_dominant=percent, dominant_class=dominant_class)
  
  return(rbind(original_df, new_group_data))  # otherwise, append the new data to the end
}

get_cluster_dominance_data <- function(records, cluster_field, num_clusters, existing_data, counts=FALSE){
  # make an empty data frame to hold the data
  for(group_num in 1:num_clusters){
    print(group_num)
    group_records <- records %>% dplyr::filter_(paste(cluster_field, "==", group_num))
    group_info <- get_dominant_stream_class_by_hucs(group_records, counts=counts)
    existing_data <- add_record_to_df(existing_data, num_clusters, group_info$result_value, group_info$class)
  }
  
  return(existing_data)
  
}

plot_dominance <- function(dominance_data){
  dominance_model <- lm(dominance_data$percent_dominant ~ dominance_data$number_clusters)
  #abline(dominance_model)
  return(plot(dominance_data$number_clusters, dominance_data$percent_dominant, cex=4, pch=19))
}

plot_dominance_gg <- function(dominance_data){
  
  # coloration via: https://stackoverflow.com/a/21146026/587938
  new_plot <- ggplot(dominance_data, aes(number_clusters, percent_dominant)) + geom_point(mapping=aes(colour=dominant_class, size=5)) + scale_colour_discrete(drop=TRUE, limits = levels(dominant_class)) + geom_smooth(method = "lm")
  
  return(new_plot)
}

region_name = "greatbasin"
species_info <- species_maps(region_name, "Great Basin")
species_info$region_map  # print the map
group_data <- species_lists_by_group_dfs(species_info$species_data, region_name)  # species_info$species_data is the data frame for the region
species_lists <- group_data$groupings
dominance_data <- group_data$dominance_data

print(plot_dominance(dominance_data))