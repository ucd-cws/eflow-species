taxa = ["Pacific_lamprey","Pacific_lamprey","Pacific_lamprey","Pacific_lamprey","Pacific_lamprey","Monterey_hitch","Southern_coastal_roach","Southern_California_steelhead","Monterey_hitch","Arroyo_chub","Southern_coastal_roach","Sacramento_speckled_dace","Unarmored_threespine_stickleback","Southern_coastal_roach","Sacramento_pikeminnow","Sacramento_pikeminnow","Central_California_coast_winter_steelhead","Sacramento_pikeminnow","Santa_Ana_speckled_dace","Sacramento_speckled_dace","Inland_threespine_stickleback","Sacramento_speckled_dace","Santa_Ana_sucker","Monterey_sucker","Tidewater_goby","Monterey_sucker","South_Central_California_coast_steelhead","South_Central_California_coast_steelhead","South_Central_California_coast_steelhead","Southern_California_steelhead","Riffle_sculpin","Inland_threespine_stickleback","Inland_threespine_stickleback","Inland_threespine_stickleback","Tidewater_goby","Unarmored_threespine_stickleback","Tidewater_goby","Tidewater_goby"]

taxa = [taxon.replace("_"," ") for taxon in taxa]

taxa_set = list(set(taxa))

for taxon in sorted(taxa_set):
	print(taxon)
	

print(len(taxa_set))