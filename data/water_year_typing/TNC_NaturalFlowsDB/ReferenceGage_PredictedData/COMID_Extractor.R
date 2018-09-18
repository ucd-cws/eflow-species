####Extract data for COMIDs listed in an external file 
#
#
mos<-c("01","02","03","04","05","06","07","08","09","10","11","12")
sts<-c("Mean")
#Load set of desired COMIDS
refs <- ref_gage_COMID
#Verify that requested COMIDs are included in CA master COMID list
cacomid<-read.csv("C:/Users/aobester/Desktop/California_COMIDs.csv",as.is=T)
#list requested COMIDs that are NOT in the master list
refs[!refs$COMID %in% cacomid$COMID,]
#
# Set temporary directory
setwd("~/modresults/")
##Loop through months and statistics, read files, combine, clean, and temporarily saves to the default directory
for(curmo in mos){
  dodo<-NULL
  for(curstat in sts){
    mns<-NULL
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/coast/",curstat,"/6.2.11_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/coast/",curstat,"/7.1.8_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/xeric/",curstat,"/11.1.3_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/xeric/",curstat,"/11.1.2_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/xeric/",curstat,"/11.1.1_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/xeric/",curstat,"/10.2.1_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/xeric/",curstat,"/10.2.2_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/xeric/",curstat,"/10.1.3_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/xeric/",curstat,"/10.1.5_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/mnts/",curstat,"/6.2.8_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/mnts/",curstat,"/6.2.7_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("X://common_geodata/flows/california_natural_flows_database/raw/mnts/",curstat,"/6.2.12_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    #remove extraneous fields
    mns<-mns[,c(1,2,3,10,9,8,7)]
    mns$Statistic<-paste(curstat)
    dodo<-rbind(dodo,mns)
    rm(biff,mns)
  }
  #Round numbers
  dodo$Estimated.Q<-round(dodo$Estimated.Q,digits=0)
  dodo$P10_Q<-round(dodo$P10_Q,digits=0)
  dodo$P90_Q<-round(dodo$P90_Q,digits=0)
  write.csv(dodo,paste("M",curmo,".csv",sep=""),row.names=F)
  
}
rm(dodo)

##Read in saved files from the default directory, sort and combine
dodo<-NULL
for(curmo in mos){
  biff<-read.csv(paste("M",curmo,".csv",sep=""))
  dodo<-rbind(dodo,biff)
  rm(biff)
}
dodo<-dodo[order(dodo$COMID,dodo$Year,dodo$Month,dodo$Statistic),]
write.csv(dodo,"COMID_Monthly_Natural_Predict.csv",row.names=F)


######### ALTERNATIVE---IF THE ECOREGION OF THE COMIDs IS ALREADY KNOWN   #################
######### AND ONLY A SINGLE STATISTIC IS WANTED 
sts<-"Mean"

## BLANK OUT ROWS FOR REGIONS THAT ARE OUTSIDE THE ONE OF INTEREST
##Loop through months and statistics, read files, combine, clean, and temporarily saves to the default directory
for(curmo in mos){
  dodo<-NULL
  for(curstat in sts){
    mns<-NULL
    #biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/COAST/",curstat,"/6.2.11_",curmo,"_Pred.csv",sep=""))
    #biff<-biff[biff$COMID %in% refs$COMID,]
    #mns<-rbind(mns,biff)
    #biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/COAST/",curstat,"/7.1.8_",curmo,"_Pred.csv",sep=""))
    #biff<-biff[biff$COMID %in% refs$COMID,]
    #mns<-rbind(mns,biff)
    biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/XERIC/",curstat,"/11.1.3_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/XERIC/",curstat,"/11.1.2_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/XERIC/",curstat,"/11.1.1_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/XERIC/",curstat,"/10.2.1_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/XERIC/",curstat,"/10.2.2_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/XERIC/",curstat,"/10.1.3_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/XERIC/",curstat,"/10.1.5_",curmo,"_Pred.csv",sep=""))
    biff<-biff[biff$COMID %in% refs$COMID,]
    mns<-rbind(mns,biff)
    #biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/MNTS/",curstat,"/6.2.8_",curmo,"_Pred.csv",sep=""))
    #biff<-biff[biff$COMID %in% refs$COMID,]
    #mns<-rbind(mns,biff)
    #biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/MNTS/",curstat,"/6.2.7_",curmo,"_Pred.csv",sep=""))
    #biff<-biff[biff$COMID %in% refs$COMID,]
    #mns<-rbind(mns,biff)
    #biff<-read.csv(paste("/Volumes/CA_TNC_Back/CA_DataV2/MNTS/",curstat,"/6.2.12_",curmo,"_Pred.csv",sep=""))
    #biff<-biff[biff$COMID %in% refs$COMID,]
    #mns<-rbind(mns,biff)
    #remove extraneous fields
    mns<-mns[,c(1,2,3,12,11,8,10)]
    mns$Statistic<-paste(curstat)
    dodo<-rbind(dodo,mns)
    rm(biff,mns)
  }
  #Round numbers
  dodo$Estimated.Q<-round(dodo$Estimated.Q,digits=0)
  dodo$P10_Q<-round(dodo$P10_Q,digits=0)
  dodo$P90_Q<-round(dodo$P90_Q,digits=0)
  write.csv(dodo,paste("M",curmo,".csv",sep=""),row.names=F)
  
}
rm(dodo)

##Read in saved files from the default directory, sort and combine
dodo<-NULL
for(curmo in mos){
  biff<-read.csv(paste("M",curmo,".csv",sep=""))
  dodo<-rbind(dodo,biff)
  rm(biff)
}
dodo<-dodo[order(dodo$COMID,dodo$Year,dodo$Month,dodo$Statistic),]
write.csv(dodo,"COMID_Monthly_Natural_Predict.csv",row.names=F)






