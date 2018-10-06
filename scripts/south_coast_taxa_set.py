taxa = ["catostomidae_catostomus_occidentalis","catostomidae_catostomus_occidentalis","catostomidae_catostomus_santaanae","catostomidae_catostomus_occidentalis","cottidae_cottus_gulosus","cottidae_cottus_gulosus","cyprinidae_gila_orcutti","cyprinidae_lavinia_exilicauda","cyprinidae_hesperoleucus_venustus","cyprinidae_hesperoleucus_venustus","cyprinidae_ptychocheilus_grandis","cyprinidae_ptychocheilus_grandis","cyprinidae_lavinia_exilicauda","cyprinidae_lavinia_exilicauda","cyprinidae_rhinichthys_osculus","petromyzontidae_entosphenus_tridentata","cyprinidae_ptychocheilus_grandis","cyprinidae_ptychocheilus_grandis","gasterosteidae_gasterosteus_aculeatus","salmonidae_oncorhynchus_mykiss","cyprinidae_rhinichthys_osculus","cyprinidae_rhinichthys_osculus","gobiidae_eucyclogobius_kristinae","NA","gasterosteidae_gasterosteus_aculeatus","gasterosteidae_gasterosteus_aculeatus","gobiidae_eucyclogobius_newberryi","NA","gobiidae_eucyclogobius_newberryi","gobiidae_eucyclogobius_newberryi","petromyzontidae_entosphenus_tridentata","NA","petromyzontidae_entosphenus_tridentata","petromyzontidae_entosphenus_tridentata","salmonidae_oncorhynchus_mykiss","NA","salmonidae_oncorhynchus_mykiss","salmonidae_oncorhynchus_mykiss"]

taxa = [taxon.replace("_"," ") for taxon in taxa]

taxa_set = list(set(taxa))

for taxon in sorted(taxa_set):
	print(taxon)
	

print(len(taxa_set))