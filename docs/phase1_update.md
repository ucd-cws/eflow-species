# Phase 1 Update Notes
This document outlines the process for clustering that has been done since the June phase 1 report. Written by Nick
Santos, September 17, 2018

Summary of changes:
* Changes to species taxonomy
* Aggregation of data to species level
* Exclusion of empty and out of state areas
* Exploration of true random seeds
* Clustering without manual region breaks
* Verification of Flow Sensitive Species Lists
* Refinements to regions

## Changes to species taxonomy
PISCES data was updated to reflect recent changes in species taxonomy, which can have an affect
on the clusters created. No changes were made to actual presence records between phase 1 and now
but the taxonomic classification information for the roach species and subspecies was verified
and corrected. Additionally, Tidewater Goby was split into northern and southern species (not
subspecies) based on Swift et al, 2016. The records remain the same, but were distributed between
two taxa, which can (and appears to) change the resulting clusters.

## Verification of Flow Sensitive Taxa Lists
Rob Lusardi looked over the list of taxa we consider to be "flow sensitive", which is based
on prior research completed and published with Ted Grantham. At this time, no changes have been
made to the list of taxa we consider to be flow sensitive. 

## Aggregation of data to species level
We recognized that species with many ESUs/DPSs/subspecies can end up having an outsize impact on
the clustering since they overlap heavily, but are considered different taxa in the clustering 
algorithm. We tested aggregating presence up to species, genus, and family levels prior to clustering
and ultimately decided that using species-level clustering was superior to subspecies, genus, or
family clustering because it produces fewer artifacts and less chaotic clusters. Subjectively
the clusters appear to be more meaningful from a management standpoint.

## Exclusion of empty and out of state areas

## Exploration of true random seeds

## Clustering without manual region breaks


## Refinements to regions

