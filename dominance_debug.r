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

group_palette <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a')

huc12_eflow_percents <- read.csv("data/HUC12s_eflow_percent.csv", stringsAsFactors = FALSE)
suffix<-"groups_num"

species_maps <-function(groupname, title, region_data){
  
  huc_data <- region_data %>% drop_na(paste(groupname,'_2groups_num', sep=""))    
  
  # now, we need to convert the attributes we're using for groupings into a single column so that GGPlot can do our mapping for us with facets
  huc_data_mapping <- gb_data %>% gather(key=model_run, value=grouping, paste(groupname,"_2",suffix, sep=""),paste(groupname,"_3",suffix, sep=""),paste(groupname,"_4",suffix, sep=""),paste(groupname,"_5",suffix, sep=""),paste(groupname,"_6",suffix, sep=""),paste(groupname,"_7",suffix, sep=""),paste(groupname,"_8",suffix, sep=""),paste(groupname,"_9",suffix, sep=""))
  
  plot <- ggplot() + 
    geom_sf(huc_data_mapping, lwd = 5, mapping=aes(fill=factor(grouping)), color=NA)+
    scale_fill_manual(values=group_palette, limits=c(1,2,3,4,5,6,7,8,9,10)) +
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
  
  data_frame <- data_frame %>% filter(!is.na(paste(group_name,'2groups_num', sep="")))
  st_geometry(data_frame) <- NULL # drop the SF geometry info
  remove_fields <- c("OBJECTID", "huc_8", "huc_10", "huc_12_string", "huc_12_double", "taxa_count", "geom_Length", "geom_Area", "oid_int_copy", "Shape_Length", "Shape_Area", "huc4","huc_region_group")
  
  data_of_interest <- select(data_frame, -one_of(remove_fields))  # filters to just the current group and removes extra fields
  
  current_field_names <-names(data_of_interest) # get the current column names
  new_field_names <- gsub("Flow_Sensitive_current_", "", current_field_names)  # replace the prefix on the fields
  
  colnames(data_of_interest) <- new_field_names
  
  # general approach we'd want here is to make vectors of the species in each group, then add to a list
  # then extend all lists to be the same length, then cbind them all to a single df and print the df
  all_groupings = list()
  for(grouping in groups){
    output_list = list()  # make an empty output list
    field_name <- paste(group_name,"_",grouping,suffix, sep="")
    for(group in seq(1,grouping)){ # for each subgroup in this grouping
      records_in_group <- data_of_interest %>% dplyr::filter_(paste(field_name, "==", as.character(group)))  # filters to just the current group
      
      records_in_group <- records_in_group[, -grep(".+groups_.+", colnames(records_in_group))]  # drop columns for groupings
      gathered_data <- as.data.frame(records_in_group) %>% tidyr::gather(key="species", value="presence")
      found_species <- gathered_data %>% dplyr::filter(presence==1) %>% distinct(species)
      g_title <- paste("group_", group, sep="")
      #colnames(found_species) <- g_title  # assign it so that the data frame field has the right name before we merge it
      #found_species <- sort(found_species, na.last=TRUE)
      output_list[[g_title]] = found_species$species  # add the group to the output list  
      
    }
    output_list <- lapply(output_list, `length<-`, max(lengths(output_list)))  # Make all of the vectors in the list the same length
    
    all_groupings[[grouping]] <- as.data.frame(output_list)
  }
  
  return(groupings=all_groupings)
}


get_dominance_data  <- function(data_frame, group_name, groups=2:9, counts=FALSE){
  st_geometry(data_frame) <- NULL # drop the SF geometry info
  group_dominance_data = data.frame(number_clusters=numeric(), value=numeric(), dominant_class=character())  # set it to NA to start - a function will create a data frame from it
  for(grouping in groups){
    field_name <- paste(group_name,"_",grouping,suffix, sep="")
    group_dominance_data <- get_cluster_dominance_data(data_frame, field_name, grouping, group_dominance_data, counts=counts)  # pass in the whole DF with the extra fields - we need the HUC 12 field
  }
  return(group_dominance_data)
}

get_dominant_stream_class_by_hucs <- function(group_records, eflow_data=huc12_eflow_percents, counts=FALSE){
  ## Given a set of records from a cluster, determines the dominant stream flow class in that cluster
  ## and the proportion of it that is the dominant class
  ## If counts is TRUE, then instead of proportion, it outputs the count as the "proportion_dominant", but
  ## it will still include the dominant class in the list output for symbolization
  
  eflow_records <- eflow_data %>% filter(HUC12 %in% group_records$huc_12_string)
  eflow_sums <- eflow_records %>% group_by(eflow_type) %>% summarise(group_sum = sum(eflow_length, na.rm=TRUE))
  max_record = which.max(eflow_sums$group_sum)
  proportion_dominant = eflow_sums[max_record,]$group_sum / sum(eflow_sums$group_sum)
  if(counts==TRUE){
    output_value = nrow(eflow_sums)
  }else{
    output_value = proportion_dominant
  }
  return(list(class=eflow_sums[max_record,]$eflow_type, result_value=output_value))
}

add_record_to_df <- function(original_df, num_groups, percent, dominant_class){
  ## This record will keep adding data to the end of the data frame about the dominance data
  if(length(percent) == 0 || length(dominant_class) == 0){  # in some cases, we get an effective null, but it's numeric(0) - we have to test the length of it to get whether or not it's this value
    return(original_df)
  }
  new_group_data = data.frame(number_clusters=num_groups, value=percent, dominant_class=dominant_class)
  
  return(rbind(original_df, new_group_data))  # otherwise, append the new data to the end
}

get_cluster_dominance_data <- function(records, cluster_field, num_clusters, existing_data, counts=FALSE){
  # make an empty data frame to hold the data
  for(group_num in 1:num_clusters){
    group_records <- records %>% dplyr::filter_(paste(cluster_field, "==", group_num))
    group_info <- get_dominant_stream_class_by_hucs(group_records, counts=counts)
    existing_data <- add_record_to_df(existing_data, num_clusters, group_info$result_value, group_info$class)
  }
  
  return(existing_data)
  
}

plot_dominance_gg <- function(dominance_data, title){
  
  # coloration via: https://stackoverflow.com/a/21146026/587938
  new_plot <- ggplot(dominance_data, aes(x=as.factor(number_clusters), y=value)) +
    geom_point(mapping=aes(colour=as.factor(dominant_class), size=5)) + 
    scale_colour_discrete(drop=TRUE, limits = levels(dominance_data$dominant_class)) +
    geom_smooth(method = "lm") +
    ggtitle(title)
  
  return(new_plot)
}

print_dominance_plots <- function(species_info, region_name){
  dominance_data <- get_dominance_data(species_info$species_data, region_name, counts=FALSE)
  print(plot_dominance_gg(dominance_data, title=paste("Percent Dominance by K Value in", region_name)))
  dominance_data <- get_dominance_data(species_info$species_data, region_name, counts=TRUE)
  print(plot_dominance_gg(dominance_data, title=paste("Number of Stream Classes by K Value in", region_name)))
}


gb_region_name <- "great_basin"
gb_species_info <- species_maps(gb_region_name, "Great Basin", huc_data)
#gb_species_info$region_map  # print the map
print_dominance_plots(gb_species_info, gb_region_name)
gb_species_lists <- species_lists_by_group_dfs(gb_species_info$species_data, gb_region_name)  # species_info$species_data is the data frame for the region
