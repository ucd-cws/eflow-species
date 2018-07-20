import os
import unittest

from PISCES import tbx_make_clusters

eflows_folder = os.path.split(os.path.split(os.path.abspath(__file__))[0])[0]  # get the parent folder on any machine, which is the main eflows folder.r

class TestTools(unittest.TestCase):

	def test_clustering(self):
		tbx_make_clusters.make_species_clusters(
			os.path.join(eflows_folder, r"data\report_update\working_scratch.gdb\june_2018_current_notrans_neighbors_7to10"),
												presence_values="1,3,9",
												min_species=0,
												num_groups=(4, 5, 6, 7),
												huc_regions=os.path.join(eflows_folder, r"data\report_update\regions.gdb\regions_without_desert"),
												region_group_field="huc_region_group",
												spatial_constraint="CONTIGUITY_EDGES_CORNERS")
												
if __name__ == "__main__":  # if this script is being run as the main script and isn't imported somewhere
	unittest.main()