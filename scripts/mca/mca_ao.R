# Using MCA/vegan to look at ordination of Species Similarities
# see this article:http://www.gastonsanchez.com/visually-enforced/how-to/2012/10/13/MCA-in-R/


# LIBRARIES ---------------------------------------------------------------

library(FactoMineR)
library(tidyverse)
library(ggthemes)
library(ggrepel)
library(vegan)

# READ DATA ---------------------------------------------------------------

##readPNG("~/GitHub/eflow-species/scripts/mca/CA_Regions.png") 
###this wont work in the rmd version of the script and i cant figure out why
#```{r echo=FALSE, out.width='100%'}
#knitr::include_graphics("~/GitHub/eflow-species/scripts/mca/CA_Regions.png")
#```

common_name_regions <- read.csv("~/GitHub/eflow-species/scripts/mca/common_name_regions.csv")
cn_reg <- common_name_regions

head(cn_reg)
str(cn_reg)

# try transforming:
cn_reg_long <- gather(cn_reg, key = "group", value = "species") %>% 
  filter(!is.na(species), !species=="")

# view number of categories per group
(cats = apply(cn_reg_long, 2, function(x) nlevels(as.factor(x))))


# MCA ---------------------------------------------------------------------

# apply MCA
mca1 = MCA(cn_reg_long, graph = F)
mca1

# table of eigenvalues
mca1$eig

# data frame with variable coordinates
mca1_vars_df = data.frame(mca1$var$coord, Variable = rep(names(cats), cats))

# data frame with observation coordinates
mca1_obs_df = data.frame(mca1$ind$coord)

# plot of variable categories
ggplot(data=mca1_vars_df, 
       aes(x = Dim.1, y = Dim.2, label = rownames(mca1_vars_df))) +
  geom_point(size=1, alpha = 0.7) +
  geom_hline(yintercept = 0, colour = "gray70") +
  geom_vline(xintercept = 0, colour = "gray70") +
  geom_text_repel(aes(colour=Variable)) +
  #scale_colour_colorblind()+
  scale_x_continuous(breaks=seq(-5,5), limits=c(-5,5)) +
  scale_y_continuous(breaks=seq(-5,5), limits=c(-5,5))+
  #geom_density2d(colour = "gray80") +
  ggtitle("MCA plot of variables using R package FactoMineR") 

#ggsave(filename = "figs/MCA_plot_cv_k4.png", width = 11, height = 8, units = "in", dpi=300)

# VEGAN -------------------------------------------------------------------

# make a 1/0 matrix 
cn_reg_mat <- cn_reg_long %>% 
  mutate(g1=if_else(group=="central_valley", 1, 0),
         g2=if_else(group=="great_basin", 1, 0),
         g3=if_else(group=="north_coast", 1, 0),
         g4=if_else(group=="south_coast", 1, 0)) %>% 
  select(-group) %>% group_by(species) %>% 
  summarize_all(sum) %>% 
  mutate(species=as.factor(species)) %>% as.data.frame()

cats = apply(cn_reg_mat, 2, function(x) nlevels(as.factor(x)))
cats

# use jaccard for 1/0 (presence absence)
spgrp.mat<-as.matrix(cn_reg_mat[,2:5])
spgrp.dist<-vegdist(spgrp.mat, method = "jaccard")

# plot a heirarchical clustering of the dissimilarity matrix (need to zoom on this plot to make it legible)
plot(hclust(spgrp.dist), labels = cn_reg_mat$species, cex=0.7)





