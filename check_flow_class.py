import os

import arcpy

base_folder = os.path.split(os.path.abspath(__file__))[0]

features_to_check = os.path.join(base_folder, r"data\contrib\flow_class.gdb\final_classification_9class")
class_field = "CLASS"
check_field = "check_status"
check_code_field = "check_code"
check_description_field = "check_description"
downstream_field = "TOCOMID"  # needs to be configured to match the actual dataset - this must be joined in from NHDPlus

flow_class_codes = {
	1: "SM",  # snowmelt
	2: "HSR",  # High-volume snowmelt and rain
	3: "LSR",  # Low-volume snowmelt and rain
	4: "WS",  # Winter storms
	5: "GW",  # groundwater
	6: "PGR",  # Perennial grounwater and rain
	7: "FER",  # Flashy, ephemeral rain
	8: "RGW",  # Rain and seasonal groundwarer
	9: "HLP",  # High elevation, low precipitation
}

valid_downstreams = {
	"SM": ["SM", "HSR", "LSR", "GW"],
	"HSR": ["HSR"],
	"LSR": ["HSR", "LSR"],
	"WS": ["HSR", "LSR", "WS", "GW", "PGR", "RGW"],
	"GW": ["SM", "HSR", "LSR", "GW", "PGR", "RGW", "HLP"],
	"PGR": ["HSR", "LSR", "GW", "PGR", "RGW"],
	"FER": ["SM", "HSR", "LSR", "WS", "GW", "PGR", "FER", "RGW", "HLP"],
	"RGW": ["HSR", "LSR", "GW", "PGR", "RGW"],
	"HLP": ["SM", "HSR", "LSR", "GW", "HLP"],
}

def downstream_is_valid(upstream_class, downstream_class):
	"""
		Checks if the downstream class is a valid class to have for this segment based on both segments' classification
	:param upstream_class:
	:param downstream_class:
	:return:
	"""
	return flow_class_codes[downstream_class] in valid_downstreams[flow_class_codes[upstream_class]]

nhd_segments = {}

class NHDSegment:
	comid = None
	downstream_comid = None
	flow_class = None
	flag_status = "unchecked"
	flag_code = None
	flag_description = None

	def __init__(self, comid, downstream_comid, flow_class):
		self.comid = comid
		self.downstream_comid = downstream_comid
		self.flow_class = flow_class

	@property
	def downstream(self, comid=None):  # gets the downstream object if configured, or sets the downstream comid if comid is provided
		if comid:
			self.downstream_comid = comid
		else:
			if self.downstream_comid and self.downstream_comid in nhd_segments:
				return nhd_segments[self.downstream_comid]
			elif not self.downstream_comid:
				raise ValueError("Can't retrieve downstream object - not yet fully loaded and don't have its comid!")
			else:
				raise ValueError("Downstream COMID {} is not present in the set of NHD Segments - can't evaluate".format(self.downstream_comid))


if __name__ == "__main__":  # if this is the main script and hasn't been imported
	print("Getting information about the input")
	describer = arcpy.Describe(features_to_check)
	field_names = [field.name for field in describer.fields]  # get just the names of the fields

	print("Adding fields if needed")
	# make sure all of our fields exist
	# add three fields for validity check - two short text and one long text
	# first short text is just 3 values "valid", "invalid", "unchecked" (or something)
	# second short text is a common code for the error - "invalid_downstream" or "short_river" or something like that
	# long field is a description of the error - "downstream code of ____ is not valid for segment with code ___
	if check_field not in field_names:
		arcpy.AddField_management(features_to_check, check_field, "TEXT")
	if check_code_field not in field_names:
			arcpy.AddField_management(features_to_check, check_code_field, "TEXT")
	if check_description_field not in field_names:
			arcpy.AddField_management(features_to_check, check_description_field, "TEXT")

	data_input = arcpy.SearchCursor(features_to_check)

	print("Reading Data")
	# read the data in so we can arbitrarily jump around it
	for row in data_input:
		nhd_segments[row.getValue("COMID")] = NHDSegment(row.getValue("COMID"), row.getValue(downstream_field), row.getValue(class_field))
	del data_input  # clear out the cursor

	# now we have all the data in a structure we can traverse

	print("Checking segments based on flow class values")
	for comid in nhd_segments: # now it's time to evaluate - currently just handles the downstream check, not the length check
		flow_class = nhd_segments[comid].flow_class
		try:
			downstream_flow_class = nhd_segments[comid].downstream.flow_class
		except ValueError as e:
			print(e)
			continue

		if not downstream_is_valid(upstream_class=flow_class, downstream_class=downstream_flow_class):
			nhd_segments[comid].downstream.flag_status = "flagged"
			nhd_segments[comid].downstream.flag_code = "suspect_flow_code"
			nhd_segments[comid].downstream.flag_description = "Flow class of {} is not in the accepted downstream flow classes for flow class {} from upstream COMID {}".format(downstream_flow_class, flow_class, comid)
		else:
			nhd_segments[comid].downstream.flag_status = "checked"

	print("Writing Results")
	# time to write it out
	data_output = arcpy.UpdateCursor(features_to_check)
	for row in data_output:
		nhd_segment = nhd_segments[row.getValue("COMID")]
		row.setValue(check_field, nhd_segment.flag_status)
		row.setValue(check_code_field, nhd_segment.flag_code)
		row.setValue(check_description_field, nhd_segment.flag_description)
		data_output.updateRow(row)
