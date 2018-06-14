# Using MCA/vegan to look at ordination of Species Similarities
# see this article:http://www.gastonsanchez.com/visually-enforced/how-to/2012/10/13/MCA-in-R/


# LIBRARIES ---------------------------------------------------------------

library(FactoMineR)
library(tidyverse)
library(ggthemes)
library(ggrepel)
library(vegan)

# READ DATA ---------------------------------------------------------------

cv_k4 <- read.csv("data/central_valley_k4.csv")

head(cv_k4)
str(cv_k4)

# try transforming:
cv_k4_long <- gather(cv_k4, key = "group", value = "species") %>% 
  filter(!is.na(species), !species=="")

# view number of categories per group
(cats = apply(cv_k4_long, 2, function(x) nlevels(as.factor(x))))


# MCA ---------------------------------------------------------------------

# apply MCA
mca1 = MCA(cv_k4_long, graph = F)
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
  geom_point(size=2) +
  geom_hline(yintercept = 0, colour = "gray70") +
  geom_vline(xintercept = 0, colour = "gray70") +
  geom_text_repel(aes(colour=Variable)) +
  scale_colour_colorblind()+
  ggtitle("MCA plot of variables using R package FactoMineR")

#ggsave(filename = "figs/MCA_plot_cv_k4.png", width = 11, height = 8, units = "in", dpi=300)

# VEGAN -------------------------------------------------------------------

# make a 1/0 matrix 
cv_k4_mat <- cv_k4_long %>% 
  mutate(g1=if_else(group=="group_1", 1, 0),
         g2=if_else(group=="group_2", 1, 0),
         g3=if_else(group=="group_3", 1, 0),
         g4=if_else(group=="group_4", 1, 0)) %>% 
  select(-group) %>% group_by(species) %>% 
  summarize_all(sum) %>% 
  mutate(species=as.factor(species)) %>% as.data.frame()

cats = apply(cv_k4_mat, 2, function(x) nlevels(as.factor(x)))
cats

# use jaccard for 1/0 (presence absence)
cv4.mat<-as.matrix(cv_k4_mat[,2:5])
cv4.dist<-vegdist(cv4.mat, method = "jaccard")

# plot a heirarchical clustering of the dissimilarity matrix (need to zoom on this plot to make it legible)
plot(hclust(cv4.dist), labels = cv_k4_mat$species, cex=0.7)

