import os

import arcpy

from PISCES import tbx_make_clusters
import arcpy_metadata

eflows_folder = os.path.split(os.path.split(os.path.abspath(__file__))[0])[0]  # get the parent folder on any machine, which is the main eflows folder.r



# 1,3,9 == current presence without translocations
# 6,7 == current translocations
# 2,10 == historically present
# 5 == extirpated
# 2,5,10 == any historical presence
# 1,7 == observed (we have a record in hand from someone who saw it)
# 1,3,6,7,9 == all currently present, including translocations

for aggregation_level in ("family", "species", "genus",):

	delta_practice = os.path.join(eflows_folder, r"data\report_update\scratch.gdb\delta_practice_{}_aggregation".format(aggregation_level))
	presence_types = "1,3,9"
	tbx_make_clusters.make_species_clusters(output_path=delta_practice,
											group_name="Flow_Sensitive",
											presence_values=presence_types,  # current presence without translocations
											min_species=0,
											num_groups=(3, 4, 5, 6, 7, 8),
											huc_regions=os.path.join(eflows_folder, r"data\report_update\regions_new.gdb\regions_wo_desert_delta"),
											region_group_field="huc_region_group",
											aggregation=aggregation_level,
											spatial_constraint="CONTIGUITY_EDGES_CORNERS")


	metadata = arcpy_metadata.MetadataEditor(delta_practice)
	metadata.purpose.set("Clustering of flow sensitive species aggregated to {} level for PISCES presence values {} using spatial constraint contiguity edges corners. New clustering run to remove Delta per group meeting. Run by Nick 8/29/18".format(presence_types,aggregation_level))
	metadata.finish()

