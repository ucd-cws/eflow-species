##FishTraits Database Trait Analysis##
##Alyssa Obester
##January 8, 2019


# data downloaded from USGS Sciencebase site: https://www.sciencebase.gov/catalog/item/5a7c6e8ce4b00f54eb2318c0
##this is what's on the fishtraits.info site, but the database is now managed by Alexa McKerrow at USGS

library(plyr)
library(dplyr)
library(tidyr)
library(corrplot)
library(qgraph)
library(reshape)
library(ggfortify)

####preliminary analysis of fishtraits vs pisces flow sensitive data####
FishTraits <- read.csv("~/GitHub/eflow-species/data/clustering/FishTraits/FishTraits.csv") 

Species_PISCES <- read.csv("~/GitHub/eflow-species/data/clustering/FishTraits/Species_PISCES.csv")
colnames(Species_PISCES)[7] <- "SCINAME"

flow_sensitive_2019 <- read.csv("~/GitHub/eflow-species/data/clustering/FishTraits/flow_sensitive_2019.csv")
colnames(flow_sensitive_2019)[1] <- "SCINAME"


#Compare FishTraits data to PISCES data used for clustering to see how many of our species are included in the fishtraits database

join_1_all_sp <- inner_join(Species_PISCES, FishTraits) #103 species match (of 340 total in PISCES; FishTraits data has 809 but coverss entire US)

#compare to flow-sensitive species

join_flow_sens <- inner_join(flow_sensitive_2019, FishTraits) #43 of 61 flow sensitive species included in FishTraits database. This is what we'll be using for the PCAs  
anti_join_flow_sens <- anti_join(flow_sensitive_2019, FishTraits) #the flow sensitive species missing from the FishTraits database

########


#cleaned up some of the data in excel (basically what was done above)
fishtraits_flow_sens_2 <- read.csv("~/fishtraits_flow_sens_2.csv")

CommonName <- as.character(fishtraits_flow_sens_2$Common.Name)

JustTraits <- fishtraits_flow_sens_2[-1] #removes the first column

rownames(JustTraits) <- CommonName #created this vector of charaacters and now assigning them to the row names of the dataset

JustTraits <- JustTraits[-1]

FinalData <- data.frame(JustTraits)

corrplot(cor(FinalData), method = "ellipse") #looks for corr amongst all variables. this isnt helpful....
corrplot(cor(FinalData), type = "upper", method = "square")

#####replacing NAs with mean and median values####

impute.mean <- function(x) replace(x, is.na(x), mean(x, na.rm = TRUE))
fishtraits_NA_mn <- ddply(fishtraits_flow_sens_2, ~ Common.Name, transform, MATUAGE = impute.mean(MATUAGE),
              LONGEVITY = impute.mean(LONGEVITY))

#This doesnt work... also want to figure out a way to loop through all the data and search for all NAs


#impute.mediam <- function(x) replace(x, is.na(x), mean(x, na.rm = TRUE))
#fishtraits_NA_med <- ddply(fishtraits_flow_sens_2, ~ Common.Name, transform, length = impute.mean(length),
              #width = impute.mean(width))

###############

####PCAs####

#PCA for all traits
PCA_all_traits <- prcomp(FinalData, scale=TRUE) #doesnt work because of NAs
#Error in colMeans(x, na.rm = TRUE) : 'x' must be numeric

FinalData_narm <- drop_na(FinalData) #removing any row (species) that contains any NAs. this takes our list of species from 43 to 19

#pca wont run on constant/zero columns, so need to remove some of them
FinalData_narm <- select(FinalData_narm, -A_1_1:-C1_3_4_C24, -SLOWCURR)

PCA_all_narm <- prcomp(FinalData_narm, scale=TRUE)

summary(PCA_all_narm)
biplot_pca_all_narm <- biplot(PCA_all_narm)

#qgraph(cor(FinalData_narm), layout = "spring", posCol = "dodgerblue", negCol = "magenta") #not helpful in this case

all_pca_plot <- autoplot(PCA_all_narm, label = TRUE, loadings.label = TRUE, label.size = 4, loadings.label.size = 2.5, loadings.colour = 'blue', loadings.label.colour = 'blue', scale = 3)
all_pca_plot



##Habitat traits only##
hab_fishtraits <- select(FinalData, MUCK:FASTCURR) #selecting only habitat pref traits

#removing NAs completely
hab_fishtraits_narm <- drop_na(hab_fishtraits) #removing any row (species) that contains any NAs. this takes our list of species from 43 to 32

corrplot(cor(hab_fishtraits_narm), method = "circle")
qgraph(cor(hab_fishtraits_narm))

PCA_hab_NArm <- prcomp(hab_fishtraits_narm, scale = TRUE)
 
PCA_hab_NArm
summary(PCA_hab_NArm)

windows()
plot(PCA_hab_NArm)
biplot_pca_hab_narm <- biplot(PCA_hab_NArm)


hab_pca_plot <- autoplot(PCA_hab_NArm, label = TRUE, loadings.label = TRUE, label.size = 4, loadings.label.size = 2.5, loadings.colour = 'blue', loadings.label.colour = 'blue')
hab_pca_plot


####


