###CHEMMINE R######

# Set working directory
setwd("C:/Users/ferfr/Downloads/planilhas_propolis_files/R testing")

library("ChemmineR")


## The SDFset object is created during the import of an SD file
sdfset <- read.SDFset("sdfset.sdf")

## Assigning compound IDs and keeping them unique
cid(sdfset)
unique_ids <- makeUnique(sdfid(sdfset))
cid(sdfset) <- unique_ids

## Converting the data blocks in SDFset to matrix
blockmatrix <- datablock2ma(datablocklist=datablock(sdfset)) # Converts data block to matrix 
numchar <- splitNumChar(blockmatrix=blockmatrix) # Splits to numeric and character matrix
numchar[[1]][1:4,]; numchar[[2]][1:4,]

## Compute atom frequency matrix, molecular weight and formula
propma <- data.frame(MF=MF(sdfset), MW=MW(sdfset), atomcountMA(sdfset))
propma[1:4, ]

## Assign matrix data to data block
datablock(sdfset) <- propma
view(sdfset[1:4])

## String Searching in SDFset
##grepSDFset("107", sdfset, field="datablock", mode="subset") # To return index, set mode="index")

## Export SDFset to SD file
# write.SDF(sdfset[1:4], file="sub.sdf", sig=TRUE)

## Plot molecule structure of one or many SDFs
##plot(sdfset[1:4]) # plots to R graphics device


###Jarvis-Patrick####
## Samples of SDFset/SDF classes

## Compute atom pair library
apset <- sdf2ap(sdfset)
fpset <- desc2fp(apset) 


## Standard Jarvis-Patrick clustering on APset/FPset objects

cl<-jarvisPatrick(nearestNeighbors(fpset,cutoff=0.7,
                                   method="Tanimoto"), k=4 , mode="b", linkage = "complete")
clusters <- byCluster(cl)
summary(clusters)
clusters

# save clusters information
 df <- summary(clusters)
 write.csv(df, file = "summary_fpset_cutoff_07_tanimoto_k_4_modeb_complete_linkage.csv")

# save each cluster
# cluster_1 <- clusters[[1]]
# write.csv(cluster_1, file = "cluster_1.csv")

# alternative for dataframe creation

# cluster_1_df <- as.data.frame(clusters[[1]])

# Automatically
library(readr)

for (i in names(clusters)){
  Temp <- as.data.frame(clusters[[i]])
  write_csv(Temp, paste("cluster_", i, ".csv", sep =""))}

# Create similarity matrix
simMA <- sapply(cid(fpset), function(x) fpSim(fpset[x], fpset, sorted=FALSE)) # Compute similarity matrix
hc <- hclust(as.dist(1-simMA), method="single") # Hierarchical clustering with simMA as input
plot(as.dendrogram(hc), edgePar=list(col=4, lwd=2), horiz=TRUE) # Plot hierarchical clustering tree

# plot as a circular dendogram (fan)
library(ape)
plot(as.phylo(hc), type = "fan")

