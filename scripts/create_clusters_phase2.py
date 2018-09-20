import os

import arcpy

from PISCES import tbx_make_clusters
import arcpy_metadata

from envmanager import EnvManager

eflows_folder = os.path.split(os.path.split(os.path.abspath(__file__))[0])[0]  # get the parent folder on any machine, which is the main eflows folder.r



# 1,3,9 == current presence without translocations
# 6,7 == current translocations
# 2,10 == historically present
# 5 == extirpated
# 2,5,10 == any historical presence
# 1,7 == observed (we have a record in hand from someone who saw it)
# 1,3,6,7,9 == all currently present, including translocations

#for aggregation_level in ("family", "species", "genus",):

#	delta_practice = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\delta_practice_{}_aggregation".format(aggregation_level))
#	presence_types = "1,3,9"
#	tbx_make_clusters.make_species_clusters(output_path=delta_practice,
#											group_name="Flow_Sensitive",
#											presence_values=presence_types,  # current presence without translocations
#											min_species=0,
#											num_groups=(3, 4, 5, 6, 7, 8),
#											huc_regions=os.path.join(eflows_folder, r"data\report_update\regions_new.gdb\regions_wo_desert_delta"),
#											region_group_field="huc_region_group",
#											aggregation=aggregation_level,
#											spatial_constraint="CONTIGUITY_EDGES_CORNERS")


#	metadata = arcpy_metadata.MetadataEditor(delta_practice)
#	metadata.purpose.set("Clustering of flow sensitive species aggregated to {} level for PISCES presence values {} using spatial constraint contiguity edges corners. New clustering run to remove Delta per group meeting. Run by Nick 8/29/18".format(presence_types,aggregation_level))
#	metadata.finish()

# aggregation_level = "species"
# delta_practice = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\nodelta_noempty_{}_aggregation_v3_2018_09_06".format(aggregation_level))
# presence_types = "1,3,9"
# tbx_make_clusters.make_species_clusters(output_path=delta_practice,
# 										group_name="Flow_Sensitive",
# 										presence_values=presence_types,  # current presence without translocations
# 										min_species=1,  # this is a shortcut to remove all the out of state areas - don't cluster empty areas
# 										num_groups=(2, 3, 4, 5, 6, 7, 8),  # added two because great_basin region is especially wonky - see what happens with only two groups
# 										huc_regions=os.path.join(eflows_folder, r"data\report_update\regions_new.gdb\regions_wo_desert_delta"),
# 										region_group_field="huc_region_group",
# 										aggregation=aggregation_level,
# 										spatial_constraint="CONTIGUITY_EDGES_CORNERS")


# metadata = arcpy_metadata.MetadataEditor(delta_practice)
# metadata.purpose = "Clustering of flow sensitive species aggregated to {} level for PISCES presence values {} using spatial constraint contiguity edges corners. New clustering run to remove Delta per group meeting. Also removing out of state areas (and anywhere else that has no species data in PISCES or no species at all - we won't cluster empty spaces on this run). Adding 2 group run for great basin. Newest version should feature truly unique taxonomic tree aggregation (because it uses family, genus, and species instead of just whichever attribute, which can be (and sometimes is) a duplicate. Run by Nick 9/6/18".format(presence_types,aggregation_level)
# metadata.finish()

#aggregation_level = "species"
#delta_practice = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\nodelta_noempty_{}_aggregation_v4_2018_09_12".format(aggregation_level))
#presence_types = "1,3,9"
#tbx_make_clusters.make_species_clusters(output_path=delta_practice,
#										group_name="Flow_Sensitive",
#										presence_values=presence_types,  # current presence without translocations
#										min_species=1,  # this is a shortcut to remove all the out of state areas - don't cluster empty areas
#										num_groups=(2, 3, 4, 5, 6, 7, 8),  # added two because great_basin region is especially wonky - see what happens with only two groups
#										huc_regions=os.path.join(eflows_folder, r"data\report_update\regions_new.gdb\regions_wo_desert_delta"),
#										region_group_field="huc_region_group",
#										aggregation=aggregation_level,
#										spatial_constraint="CONTIGUITY_EDGES_CORNERS")


#metadata = arcpy_metadata.MetadataEditor(delta_practice)
#metadata.purpose = "Clustering of flow sensitive species aggregated to {} level for PISCES presence values {} using spatial constraint contiguity edges corners. New clustering run to remove Delta per group meeting. Also removing out of state areas (and anywhere else that has no species data in PISCES or no species at all - we won't cluster empty spaces on this run). Adding 2 group run for great basin. Newest version should feature truly unique taxonomic tree aggregation (because it uses family, genus, and species instead of just whichever attribute, which can be (and sometimes is) a duplicate. This version also reflects taxonomic changes and corrections in PISCES, specifically to Roach subspecies and to the split between Tidewater Goby. Run by Nick 9/12/18".format(presence_types,aggregation_level)
#metadata.finish()

def random_seed_change_test():
	random_seed_starts = ("20180914 ACM599", "68 ACM599", "14 ACM599", "2018 ACM599", "4 ACM599", "20180914 MERSENNE_TWISTER", "20180914 STANDARD_C")
	aggregation_level = "species"
	presence_types = "1,3,9"
	spatial_constraint = "NO_SPATIAL_CONSTRAINT"
	initialization_method = "USE_RANDOM_SEEDS"

	for seed in random_seed_starts:
		with EnvManager(randomGenerator=seed):

			output_path = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\nodelta_noempty_{}_aggregation_v6_seed_{}_2018_09_15".format(aggregation_level, seed.replace(" ","_")))
			tbx_make_clusters.make_species_clusters(output_path=output_path,
													group_name="Flow_Sensitive",
													presence_values=presence_types,  # current presence without translocations
													min_species=1,  # this is a shortcut to remove all the out of state areas - don't cluster empty areas
													num_groups=(8,),  # added two because great_basin region is especially wonky - see what happens with only two groups
													huc_regions=os.path.join(eflows_folder, r"data\report_update\regions_new.gdb\regions_wo_desert_delta"),
													region_group_field="huc_region_group",
													aggregation=aggregation_level,
													spatial_constraint=spatial_constraint,
													initialization_method=initialization_method,
													report_folder=os.path.join(eflows_folder, "data", "cluster_reports", os.path.split(output_path)[1]))


			metadata = arcpy_metadata.MetadataEditor(output_path)
			metadata.purpose = "Clustering of flow sensitive species aggregated to {} level for PISCES presence values {}." \
							   " This version uses a new random seed. New clustering run to remove Delta per group meeting. " \
							   "Also removing out of state areas (and anywhere else that has no species data in PISCES or " \
							   "no species at all - we won't cluster empty spaces on this run). Adding 2 group run for great " \
							   "basin. Newest version should feature truly unique taxonomic tree aggregation (because it uses " \
							   "family, genus, and species instead of just whichever attribute, which can be " \
							   "(and sometimes is) a duplicate. This version also reflects taxonomic changes and " \
							   "corrections in PISCES, specifically to Roach subspecies and to the split between" \
							   " Tidewater Goby. Initialization method for Kmeans was {} and spatial constraing was {}." \
							   " Run by Nick 9/15/18".format(presence_types,aggregation_level, initialization_method, spatial_constraint)
			metadata.finish()

def statewide_2018_09_16():
	aggregation_level = "species"
	presence_types = "1,3,9"
	spatial_constraint = "NO_SPATIAL_CONSTRAINT"
	initialization_method = "FIND_SEED_LOCATIONS"
	seed = "20180916 ACM599"
	with EnvManager(randomGenerator=seed):
		output_path = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\nodelta_noempty_{}_aggregation_statewide_v7_seed_{}_2018_09_16".format(aggregation_level, seed.replace(" ","_")))
		tbx_make_clusters.make_species_clusters(output_path=output_path,
												group_name="Flow_Sensitive",
												presence_values=presence_types,  # current presence without translocations
												min_species=1,  # this is a shortcut to remove all the out of state areas - don't cluster empty areas
												num_groups=(5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32),  # added two because great_basin region is especially wonky - see what happens with only two groups
												huc_regions=os.path.join(eflows_folder, r"data\report_update\regions_new.gdb\regions_wo_desert_delta"),
												region_group_field=None,
												aggregation=aggregation_level,
												spatial_constraint=spatial_constraint,
												initialization_method=initialization_method,)


		metadata = arcpy_metadata.MetadataEditor(output_path)
		metadata.purpose = 	metadata.purpose = "Clustering of flow sensitive species aggregated to {} level for PISCES presence values {}." \
						" In this clustering run, we ran the clustering statewide, without region breakouts." \
						" This version excludes the Delta and empty areas. This version also reflects taxonomic changes and " \
						"corrections in PISCES, specifically to Roach subspecies and to the split between" \
						" Tidewater Goby. Spatial constraint was {} and initialization method was {}. Random seed was {}" \
						" Run by Nick 9/16/18".format(presence_types, aggregation_level,spatial_constraint, initialization_method, seed)
		metadata.finish()

	spatial_constraint = "CONTIGUITY_EDGES_CORNERS"
	output_path = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\nodelta_noempty_{}_aggregation_statewide_v8_2018_09_16".format(aggregation_level))
	tbx_make_clusters.make_species_clusters(output_path=output_path,
											group_name="Flow_Sensitive",
											presence_values=presence_types,  # current presence without translocations
											min_species=1,  # this is a shortcut to remove all the out of state areas - don't cluster empty areas
											num_groups=(5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
														25, 26, 27, 28, 29, 30, 31, 32),
											# added two because great_basin region is especially wonky - see what happens with only two groups
											huc_regions=os.path.join(eflows_folder, r"data\report_update\regions_new.gdb\regions_wo_desert_delta"),
											region_group_field=None,
											aggregation=aggregation_level,
											spatial_constraint=spatial_constraint,
											initialization_method=initialization_method,
											report_folder=os.path.join(eflows_folder, "data", "cluster_reports", os.path.split(output_path)[1]))


	metadata = arcpy_metadata.MetadataEditor(output_path)
	metadata.purpose = "Clustering of flow sensitive species aggregated to {} level for PISCES presence values {}." \
						" In this clustering run, we ran the clustering statewide, without region breakouts. " \
						" This version excludes the Delta and empty areas. This version also reflects taxonomic changes and " \
						"corrections in PISCES, specifically to Roach subspecies and to the split between" \
						" Tidewater Goby. Spatial constraint was {}. Run by Nick 9/16/18".format(presence_types, aggregation_level,spatial_constraint)
	metadata.finish()

def species_subspecies_2018_09_16():

	presence_types = "1,3,9"
	aggregation_level = "fid"
	spatial_constraint = "CONTIGUITY_EDGES_CORNERS"
	output_path = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\nodelta_noempty_no_aggregation_v10_2018_09_16")
	tbx_make_clusters.make_species_clusters(output_path=output_path,
											group_name="Flow_Sensitive",
											presence_values=presence_types,  # current presence without translocations
											min_species=1,  # this is a shortcut to remove all the out of state areas - don't cluster empty areas
											num_groups=(2, 3, 4, 5, 6, 7, 8),
											# added two because great_basin region is especially wonky - see what happens with only two groups
											huc_regions=os.path.join(eflows_folder, r"data\report_update\regions_new.gdb\regions_wo_desert_delta"),
											region_group_field="huc_region_group",
											aggregation=aggregation_level,
											spatial_constraint=spatial_constraint,)


	metadata = arcpy_metadata.MetadataEditor(output_path)
	metadata.purpose = "Clustering of flow sensitive species unaggregated for PISCES presence values {}. This" \
					   " version was run to compare against statewide clustering and subspecies aggregation with our other" \
					   "settings fixed." \
						" This version excludes the Delta and empty areas. This version also reflects taxonomic changes and " \
						"corrections in PISCES, specifically to Roach subspecies and to the split between" \
						" Tidewater Goby. Spatial constraint was {}. Run by Nick 9/16/18".format(presence_types, aggregation_level, spatial_constraint)
	metadata.finish()

	aggregation_level = "species"
	output_path = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\nodelta_noempty_{}_aggregation_v9_2018_09_16".format(aggregation_level))
	tbx_make_clusters.make_species_clusters(output_path=output_path,
											group_name="Flow_Sensitive",
											presence_values=presence_types,  # current presence without translocations
											min_species=1,  # this is a shortcut to remove all the out of state areas - don't cluster empty areas
											num_groups=(2, 3, 4, 5, 6, 7, 8),
											# added two because great_basin region is especially wonky - see what happens with only two groups
											huc_regions=os.path.join(eflows_folder, r"data\report_update\regions_new.gdb\regions_wo_desert_delta"),
											region_group_field="huc_region_group",
											aggregation=aggregation_level,
											spatial_constraint=spatial_constraint,)


	metadata = arcpy_metadata.MetadataEditor(output_path)
	metadata.purpose = "Clustering of flow sensitive species aggregated to {} level for PISCES presence values {}. This" \
					   " version was run to compare against statewide clustering and subspecies aggregation with our other" \
					   "settings fixed." \
						" This version excludes the Delta and empty areas. This version also reflects taxonomic changes and " \
						"corrections in PISCES, specifically to Roach subspecies and to the split between" \
						" Tidewater Goby. Spatial constraint was {}. Run by Nick 9/16/18".format(presence_types, aggregation_level,spatial_constraint)
	metadata.finish()


def subspecies_2018_09_17():

	presence_types = "1,3,9"
	aggregation_level = "common_name"
	spatial_constraint = "CONTIGUITY_EDGES_CORNERS"
	output_path = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\noestuary_noempty_no_aggregation_v11_2018_09_17")
	tbx_make_clusters.make_species_clusters(output_path=output_path,
											group_name="Flow_Sensitive",
											presence_values=presence_types,  # current presence without translocations
											min_species=1,  # this is a shortcut to remove all the out of state areas - don't cluster empty areas
											num_groups=(2, 3, 4, 5, 6, 7, 8),
											# added two because great_basin region is especially wonky - see what happens with only two groups
											huc_regions=os.path.join(eflows_folder, r"data\regions\regions.gdb\regions_noesturary_nodesert_2018_09_17"),
											region_group_field="huc_region_group",
											aggregation=aggregation_level,
											spatial_constraint=spatial_constraint,)


	metadata = arcpy_metadata.MetadataEditor(output_path)
	metadata.purpose = "Clustering of flow sensitive species unaggregated for PISCES presence values {}. This version" \
					   "uses new regions where HUCs in HUC_10 1805000101 were moved from the north_coast region to the" \
					   "central_valley because they all drain out Suisun Marsh and HUCs in the same HUC_10s as the San Francisco" \
					   "Bay, including the Bay itself, were removed in order to get rid of weird behavior in North Coast" \
					   "clustering. These estuary HUCs and the Delta HUCs will need to be managed separately from this" \
					   "clustering. This version excludes empty areas. This version also reflects taxonomic changes and " \
						"corrections in PISCES, specifically to Roach subspecies and to the split between" \
						" Tidewater Goby. Spatial constraint was {}. Run by Nick 9/17/18".format(presence_types, spatial_constraint)
	metadata.finish()

def species_2018_09_17():
	presence_types = "1,3,9"
	spatial_constraint = "CONTIGUITY_EDGES_CORNERS"
	aggregation_level = "species"
	output_path = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\noestuary_noempty_{}_aggregation_v13_2018_09_17".format(aggregation_level))
	tbx_make_clusters.make_species_clusters(output_path=output_path,
											group_name="Flow_Sensitive",
											presence_values=presence_types,  # current presence without translocations
											min_species=1,  # this is a shortcut to remove all the out of state areas - don't cluster empty areas
											num_groups=(2, 3, 4, 5, 6, 7, 8),
											# added two because great_basin region is especially wonky - see what happens with only two groups
											huc_regions=os.path.join(eflows_folder, r"data\regions\regions.gdb\regions_noesturary_nodesert_2018_09_17"),
											region_group_field="huc_region_group",
											aggregation=aggregation_level,
											spatial_constraint=spatial_constraint,)


	metadata = arcpy_metadata.MetadataEditor(output_path)
	metadata.purpose = "Clustering of flow sensitive species aggregated to the {} level for PISCES presence values {}. This version" \
					   "uses new regions where HUCs in HUC_10 1805000101 were moved from the north_coast region to the" \
					   "central_valley because they all drain out Suisun Marsh and HUCs in the same HUC_10s as the San Francisco" \
					   "Bay, including the Bay itself, were removed in order to get rid of weird behavior in North Coast" \
					   "clustering. These estuary HUCs and the Delta HUCs will need to be managed separately from this" \
					   "clustering. This version excludes empty areas. This version also reflects taxonomic changes and " \
						"corrections in PISCES, specifically to Roach subspecies and to the split between" \
						" Tidewater Goby. Spatial constraint was {}. Run by Nick 9/17/18".format(presence_types, aggregation_level, spatial_constraint)
	metadata.finish()

if __name__ == "__main__":  # basically, this line only runs if this is the primary script being executed, rather than an imported file
	# statewide_2018_09_16()
	species_2018_09_17()