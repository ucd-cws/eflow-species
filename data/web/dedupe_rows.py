import re
import csv
import os

import PISCES
PISCES.local_vars.data_setup()  # we'll use this for validation

base_dir = os.path.dirname(os.path.abspath(__file__))
input_filepath = os.path.join(base_dir, "huc_assemblages.csv")
output_filepath = os.path.join(base_dir, "huc_assemblages_v2_sorted.csv")

name_field = "huc_12_string"
assemblage_field = "current_assemblage"

def dedupe_field(field_value):
	"""
		Splits a comma separated list, deduplicates it, and rejoins to a string
	"""
	taxa = re.findall("\w[\w\s\-]+", field_value)
	new_field_items = sorted(list(set(taxa)))

	for item in new_field_items:
		# do a sanity check - make sure this common name exists in PISCES
		for fish_id in PISCES.local_vars.all_fish:
			if PISCES.local_vars.all_fish[fish_id].species.lower() == item.lower():  # if it exists as a fish in PISCES
				break
		else:
			raise ValueError("Split fish {} does not exist in PISCES".format(item))

	return ", ".join(new_field_items)
	
with open(input_filepath, 'r') as input_data:
	with open(output_filepath, 'wb') as output_data:
	
		reader = csv.DictReader(input_data)
		print(reader.fieldnames)
		writer = csv.DictWriter(output_data, reader.fieldnames)
		
		writer.writeheader()
		for row in reader:
			writer.writerow({name_field: row[name_field],
							assemblage_field: dedupe_field(row[assemblage_field])
							})
			