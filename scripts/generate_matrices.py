import PISCES

PISCES.tbx_make_matrix.make_matrix("Anadromous", r"C:\Users\dsx\Projects\eflows_working\species_matrices", out_name="anadromous_current")
PISCES.tbx_make_matrix.make_matrix("Wide_Ranging", r"C:\Users\dsx\Projects\eflows_working\species_matrices", out_name="Wide_Ranging_current")
PISCES.tbx_make_matrix.make_matrix("Narrow_25", r"C:\Users\dsx\Projects\eflows_working\species_matrices", out_name="Narrow_25_current")
PISCES.tbx_make_matrix.make_matrix("Anadromous", r"C:\Users\dsx\Projects\eflows_working\species_matrices", presence_types="1,5,10", out_name="anadromous_historical")
PISCES.tbx_make_matrix.make_matrix("Wide_Ranging", r"C:\Users\dsx\Projects\eflows_working\species_matrices", presence_types="1,5,10", out_name="Wide_Ranging_historical")
PISCES.tbx_make_matrix.make_matrix("Narrow_25", r"C:\Users\dsx\Projects\eflows_working\species_matrices", presence_types="1,5,10", out_name="Narrow_25_historical")

PISCES.tbx_make_matrix.make_matrix("Flow_Sensitive", r"C:\Users\dsx\Projects\eflows_working\species_matrices", out_name="Flow_Sensitive_current")
PISCES.tbx_make_matrix.make_matrix("Flow_Sensitive", r"C:\Users\dsx\Projects\eflows_working\species_matrices", presence_types="1,5,10", out_name="Flow_Sensitive_historical")
