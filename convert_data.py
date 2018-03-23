"""
	Given a set of HUCs that are dissolved so that they only have one feature per HUC ID (and that already have a field
	that's an integer ID
"""

import os
import six

import arcpy



main_db = r"C:\Users\dsx\Projects\eflows_working\eflows_arcgis.gdb"
output_db = r"C:\Users\dsx\Projects\eflows_working\eflows_matrices.gdb"
base_hucs = "HUCs_dissolved"

species_groups = [
	"Native_Fish",
	"All_Fish",
	#"Narrow_25",
	#"Wide_Ranging",
	#"Anadromous",
	#"Flow_Sensitive",
]

presence_types = [
	"current",
	"historical",
]

hucs = os.path.join(main_db, base_hucs)
filtered_hucs = os.path.join(output_db, "hucs_filtered")
hucs_layer = "hucs_layer"


if arcpy.Exists(filtered_hucs):
	arcpy.Delete_management(filtered_hucs)

print("Filtering HUCs to only in-state")
arcpy.MakeFeatureLayer_management(hucs, hucs_layer, where_clause="HUC_12 not Like 'M%'")
arcpy.CopyFeatures_management(hucs_layer, filtered_hucs)
arcpy.Delete_management(hucs_layer)

hucs = filtered_hucs
try:
	print("Converting HUC_12 ID to Double Precision")
	arcpy.AddField_management(hucs, "huc_id", "DOUBLE")
except:  # this could fail for reasons we don't want to pass on, but we'll still fail in the next step - putting this here because it's saying field already exists
	pass
arcpy.CalculateField_management(hucs, "huc_id", "float(!HUC_12!)", "Python3" if six.PY3 else "Python9.3")


arcpy.MakeFeatureLayer_management(hucs, hucs_layer, where_clause="HUC_12 not Like 'M%'")

for name in species_groups:  # run this for every group/presence type combo
	for ptype in presence_types:
		print("Working on {}:{}".format(name, ptype))
		table = os.path.join(main_db, "{}_{}".format(name, ptype))
		#arcpy.AddField_management(table, "huc_id", "DOUBLE")
		#arcpy.CalculateField_management(table, "huc_id", "float(!HUC_12!)", "Python3" if six.PY3 else "Python9.3")

		arcpy.AddJoin_management(hucs_layer, "huc_id", table, "HUC_12")
		features = os.path.join(output_db, "HUCs_{}_{}".format(name, ptype))
		arcpy.CopyFeatures_management(hucs_layer, features)
		print("Removing Join {}".format(table))
		arcpy.RemoveJoin_management(hucs_layer, os.path.split(table)[1])



