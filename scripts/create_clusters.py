from PISCES import tbx_make_clusters

class TestTools(unittest.TestCase):

	def test_clustering(self):
		tbx_make_clusters.make_species_clusters(r"C:\Users\dsx\Code\eflow-species\data\report_update\working_scratch.gdb\june_2018_current_notrans_neighbors_7to10",\
												presence_values="1,3,9",
												min_species=0,
												num_groups=(4, 5, 6, 7),
												huc_regions=r"C:\Users\dsx\Code\eflow-species\data\report_update\regions.gdb\regions_without_desert",
												region_group_field="huc_region_group",
												spatial_constraint="CONTIGUITY_EDGES_CORNERS")