import os

import arcpy

base_folder = os.path.split(os.path.abspath(__file__))[0]

features_to_check = os.path.join(base_folder, r"data\contrib\flow_class.gdb\final_classification_9class")
CLASS_FIELD = "CLASS"
CHECK_FIELD = "check_status"
CHECK_CODE_FIELD = "check_code"
CHECK_DESCRIPTION_FIELD = "check_description"
DOWNSTREAM_FIELD = "TOCOMID"  # needs to be configured to match the actual dataset - this must be joined in from NHDPlus
DRAINAGE_AREA_FIELD = "TotDASqKm"  ## TODO: Make this the correct field name - filling in the NHDPlus default info for now
MAJOR_TRIBUTARY_THRESHOLD = 0.25  # What proportion of downstream flow must a segment comprise before it's a major tributary to downstream

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
	"RGW": ["HSR", "LSR", "WS", "GW", "PGR", "RGW"],
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


class NHDSegment(object):
	comid = None
	downstream_comid = None
	flow_class = None
	drainage_area = None
	flag_status = []
	flag_code = []
	flag_description = []

	def __init__(self, comid, downstream_comid, flow_class, drainage_area):
		self.comid = comid
		self.downstream_comid = downstream_comid
		self.flow_class = flow_class
		self.drainage_area = drainage_area

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

	@property
	def is_major_tributary(self):
		"""
			Checks if the upstream area in this segment is more than 25% of the total upstream area in the downstream segment.
			If not, logic elsewhere will ignore the rules for this segment.
		:return: boolean
		"""

		if self.drainage_area > 0.25 * self.downstream.drainage_area:
			return True
		else:
			return False


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
	if CHECK_FIELD not in field_names:
		arcpy.AddField_management(features_to_check, CHECK_FIELD, "TEXT")
	if CHECK_CODE_FIELD not in field_names:
			arcpy.AddField_management(features_to_check, CHECK_CODE_FIELD, "TEXT")
	if CHECK_DESCRIPTION_FIELD not in field_names:
			arcpy.AddField_management(features_to_check, CHECK_DESCRIPTION_FIELD, "TEXT")

	data_input = arcpy.SearchCursor(features_to_check)

	print("Reading Data")
	# read the data in so we can arbitrarily jump around it
	for row in data_input:
		nhd_segments[row.getValue("COMID")] = NHDSegment(row.getValue("COMID"), row.getValue(DOWNSTREAM_FIELD), row.getValue(CLASS_FIELD))
	del data_input  # clear out the cursor

	# now we have all the data in a structure we can traverse

	print("Checking segments based on flow class values")
	checked_items = 0
	for comid in nhd_segments: # now it's time to evaluate - currently just handles the downstream check, not the length check
		checked_items += 1
		if checked_items % 10000 == 0:  # every time we evaluate 10k items
			print(checked_items)

		flow_class = nhd_segments[comid].flow_class
		try:
			downstream_flow_class = nhd_segments[comid].downstream.flow_class
		except ValueError as e:
			nhd_segments[comid].flag_status.append("flagged")
			nhd_segments[comid].flag_code.append("network_issue")
			nhd_segments[comid].flag_description.append("The status of this segment was unable to be evaluated due to coding or incorrect network information - error raised was \"{}\"".format(str(e)))
			continue

		if not nhd_segments[comid].is_major_tributary:
			if len(nhd_segments[comid].downstream.flag_status) == 0:  # only set the status if there *is* no status already - we'll likely overwrite it later when we get the major tributary
				nhd_segments[comid].downstream.flag_status.append("skipped")  # set it to skipped so that we know if there was no major trib. If there is, it'll be overwritten. We're more likely to get two major tribs, probably
				nhd_segments[comid].flag_code.append("skipped")
				nhd_segments[comid].flag_description.append("skipped")
			continue

		if not downstream_is_valid(upstream_class=flow_class, downstream_class=downstream_flow_class):
			nhd_segments[comid].downstream.flag_status.append("flagged")
			nhd_segments[comid].downstream.flag_code.append("suspect_flow_code")
			nhd_segments[comid].downstream.flag_description.append("Flow class of {} is not in the accepted downstream flow classes for flow class {} from upstream COMID {}".format(downstream_flow_class, flow_class, comid))
		else:
			nhd_segments[comid].downstream.flag_status.append("checked")
			nhd_segments[comid].flag_code.append("checked")
			nhd_segments[comid].flag_description.append("checked")


	print("Writing Results")
	# time to write it out
	data_output = arcpy.UpdateCursor(features_to_check)
	for row in data_output:
		nhd_segment = nhd_segments[row.getValue("COMID")]
		row.setValue(CHECK_FIELD, ",".join(nhd_segment.flag_status))
		row.setValue(CHECK_CODE_FIELD, ",".join(nhd_segment.flag_code))
		row.setValue(CHECK_DESCRIPTION_FIELD, ",".join(nhd_segment.flag_description))
		data_output.updateRow(row)
