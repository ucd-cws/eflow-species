import arcpy

class Env(object):
	"""
		Acts as a drop-in replacement for EnvManagers in Pro
	"""
	def __init__(self, **kwargs):
		self.new_values = kwargs
		self.orig_values = {}
		for env in kwargs:  # back up the original values
			self.orig_values[env] = arcpy.env.__getitem__(env)

	def __enter__(self, *args, **kwargs):
		for env in self.new_values:
			arcpy.env.__setitem__(env, self.new_values[env])

	def __exit__(self, *args, **kwargs):
		self.reset()

	def reset(self):
		for env in self.orig_values:
			arcpy.env.__setitem__(env, self.orig_values[env])

if hasattr(arcpy, "EnvManager"):
	EnvManager = arcpy.EnvManager
else:
	EnvManager = Env