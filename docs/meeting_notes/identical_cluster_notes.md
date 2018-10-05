So, maybe we display the data where we show a count of the HUCs that each species is in within a cluster (or percent)
Could also use it as a ranking.

| HUC_12 | species_fields | region | cluster | huc assemblage
                                    north_coast_3


Click on HUC
-- Cluster Assemblage:
        Central Valley fall run Chinook (Cluster HUC count: 31/303 (~10%)) (Range HUC count 31/126 (~20%))
        ... ordered by cluster HUC count (desc)
        ... still not including translocations anywhere
        
-- HUC Assemblage
        doesn't actually include all cluster taxa
        Hardhead
        
-- Region
-- Cluster boundary



Overlay is region boundary and cluster coloration

Export tables of all cluster assemblage (and percent info) for each region so that people don't need to be clicking
back and forth between two clusters. (Might need to do it partially by hand for expediency)

Maybe 


* Implementation-wise, we will have PISCES output the assemblages as an attribute.
* Use Join Field to attach to a copy to clusters
* Add a field with the first letter of the region name and the number of the cluster so that everything is in
one field for our chosen clusters
* Get a cluster/region set of species counts (count_nonzero in R with a group_by region and group_by new
cluster field) as a lookup table. 
* We also want to have two lookups - one with the sum of hucs in a species range, and one with the
 sum of HUCs in a cluster. We'll use these when making the cluster assemblages 
* We'll then modify our existing code that gets cluster assemblages to use the lookup tables to find the
proportion of a species range and the proportion of the cluster size that the species represents. Then
we'll need some sort of (paste loop? or is there a .join in R?)
