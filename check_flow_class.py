import os

import arcpy

base_folder = os.path.split(os.path.abspath(__file__))[0]

features_to_check = os.path.join(base_folder, r"data\contrib\flow_class.gdb\final_classification_9class")
CLASS_FIELD = "CLASS"
CHECK_FIELD = "check_status"
CHECK_CODE_FIELD = "check_code"
CHECK_DESCRIPTION_FIELD = "check_description"
DOWNSTREAM_FIELD = "TOCOMID"  # needs to be configured to match the actual dataset - this must be joined in from NHDPlus
DRAINAGE_AREA_FIELD = "DivDASqKM"  ## Using the divergence-routed upstream area field so that our percentage flow calculation works correctly
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

	def __init__(self, comid, downstream_comid, flow_class, drainage_area):
		self.comid = comid
		self.downstream_comid = downstream_comid
		self.flow_class = flow_class
		self.drainage_area = drainage_area
		self.flag_status = []
		self.flag_code = []
		self.flag_description = []
		self.upstream = []

	@property
	def downstream(self, comid=None):  # gets the downstream object if configured, or sets the downstream comid if comid is provided
		if comid:
			self.downstream_comid = comid
		else:
			if self.downstream_comid and self.downstream_comid in nhd_segments:
				return nhd_segments[int(self.downstream_comid)]
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


def build_network(segments):
	for segment_id in segments:
		segment = segments[segment_id]
		try:
			if segment not in segment.downstream.upstream:
				segment.downstream.upstream.append(segment)
		except ValueError:
			continue  # we'll get that if the downstream doesn't exist - skip it


def check_flow_classes():
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
			arcpy.AddField_management(features_to_check, CHECK_DESCRIPTION_FIELD, "TEXT", field_length=8192)

	data_input = arcpy.SearchCursor(features_to_check)

	print("Reading Data")
	# read the data in so we can arbitrarily jump around it
	for row in data_input:
		nhd_segments[row.getValue("COMID")] = NHDSegment(row.getValue("COMID"), row.getValue(DOWNSTREAM_FIELD), row.getValue(CLASS_FIELD), row.getValue(DRAINAGE_AREA_FIELD))
	del data_input  # clear out the cursor

	print("Building Upstream Network")
	build_network(nhd_segments)

	# now we have all the data in a structure we can traverse

	print("Checking segments based on flow class values")
	checked_items = 0
	for comid in nhd_segments: # now it's time to evaluate - currently just handles the downstream check, not the length check
		checked_items += 1
		if checked_items % 10000 == 0:  # every time we evaluate 10k items
			print(checked_items)

		current_segment = nhd_segments[comid]
		flow_class = current_segment.flow_class
		try:
			downstream_flow_class = current_segment.downstream.flow_class
		except ValueError as e:
			current_segment.flag_status.append("flagged")
			current_segment.flag_code.append("network_issue")
			current_segment.flag_description.append("The status of this segment was unable to be evaluated due to coding or incorrect network information - error raised was \"{}\"".format(str(e)))
			continue

		if not current_segment.is_major_tributary:
			if len(current_segment.downstream.flag_status) == 0:  # only set the status if there *is* no status already - we'll likely overwrite it later when we get the major tributary
				current_segment.downstream.flag_status.append("skipped")  # set it to skipped so that we know if there was no major trib. If there is, it'll be overwritten. We're more likely to get two major tribs, probably
				current_segment.flag_code.append("skipped")
				current_segment.flag_description.append("skipped")
			continue

		if not downstream_is_valid(upstream_class=flow_class, downstream_class=downstream_flow_class):
			# if the flow class is invalid, check if the downstream flow class is valid for *any* of the upstream items
			for upstream in current_segment.downstream.upstream:
				if upstream is current_segment:  # no need to recheck the current item, which will be the case most times
					continue
				if upstream.is_major_tributary and downstream_is_valid(upstream_class=upstream.flow_class, downstream_class=downstream_flow_class):
					break  # if we find a valid upstream/downstream relationship, break out of this loop
			else:  # otherwise, flag the downstream segment
				current_segment.downstream.flag_status.append("flagged")
				current_segment.downstream.flag_code.append("suspect_flow_code")
				current_segment.downstream.flag_description.append("Flow class of {} is not in the accepted downstream flow classes for flow class {} from upstream COMID {}".format(downstream_flow_class, flow_class, comid))
				continue  # continue here so that the "checked" below is skipped

		current_segment.downstream.flag_status.append("checked")
		current_segment.flag_code.append("checked")
		current_segment.flag_description.append("checked")


	print("Writing Results")
	# time to write it out
	data_output = arcpy.UpdateCursor(features_to_check)
	for row in data_output:
		nhd_segment = nhd_segments[row.getValue("COMID")]
		try:
			row.setValue(CHECK_FIELD, ",".join(nhd_segment.flag_status))
			row.setValue(CHECK_CODE_FIELD, ",".join(nhd_segment.flag_code))
			row.setValue(CHECK_DESCRIPTION_FIELD, ",".join(nhd_segment.flag_description))
			data_output.updateRow(row)
		except RuntimeError:
			print("COMID: {}".format(comid))
			print("CHECK_FIELD: {}".format(",".join(nhd_segment.flag_status)))
			print("CHECK_CODE_FIELD: {}".format(",".join(nhd_segment.flag_code)))
			print("CHECK_DESCRIPTION_FIELD: {}".format(",".join(nhd_segment.flag_description)))
			raise

if __name__ == "__main__":  # if this is the main script and hasn't been imported
	check_flow_classes()
