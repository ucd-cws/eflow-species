import os

from PISCES import tbx_make_clusters
import arcpy

eflows_folder = os.path.split(os.path.split(os.path.abspath(__file__))[0])[0]  # get the parent folder on any machine, which is the main eflows folder.r



# 1,3,9 == current presence without translocations
# 6,7 == current translocations
# 2,10 == historically present
# 5 == extirpated
# 2,5,10 == any historical presence
# 1,7 == observed (we have a record in hand from someone who saw it)
# 1,3,6,7,9 == all currently present, including translocations

arcpy.env.randomGenerator = "ACM599"
tbx_make_clusters.make_species_clusters(output_path=os.path.join(eflows_folder, r"data\report_update\working_scratch.gdb\june_2018_current_notrans_neighbors_7to10"),
										group_name="Flow_Sensitive",
										presence_values="1,3,9", # current presence without translocations
										min_species=0,
										num_groups=(4, 5, 6, 7),
										huc_regions=os.path.join(eflows_folder, r"data\report_update\regions.gdb\regions_without_desert"),
										region_group_field="huc_region_group",
										spatial_constraint="CONTIGUITY_EDGES_CORNERS")
