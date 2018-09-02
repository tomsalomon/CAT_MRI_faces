# create RData file for all participants
library(lme4)

rm(list=ls())

Group = 1 # 1- experimental group; 2- control group
sessionNum = 1 # 1- session 1 ; 2- follow-up

path="/Users/rotembotvinik/Google_Drive/my_research/experiments/BMI_MRI_snacks_40/BMI_MRI_snacks_40/Output/"

# define which subjects
if (Group==1 & sessionNum==1) {
  #subjects=c(102:108, 110:121, 123:135, 137:141) 
  subjects=c(102:108, 110:121, 123:128, 130:135, 137:141) 
  experimentName = "MRI_snacks"
} else if (Group==2 & sessionNum==1) {
  subjects=c(101:103, 105:121, 123:140) 
  experimentName = "MRI_snacks2"
} else if (Group==1 & sessionNum==2) {
  subjects=c(103:108, 110:111, 113:116, 118:120, 123:128 ,132:135, 138, 140) 
  experimentName = "MRI_snacks"
} else if (Group==2 & sessionNum==2) {
  subjects=c(101:103, 105:108, 110:113, 115:120, 123, 127:129, 131, 135:136)
  experimentName = "MRI_snacks2"
}


# Excluded:
# experimental group: 109, 122
# control group: 104, 122


# define blocks:
if (sessionNum==1){
  blocks=c(1:2)
} else if (sessionNum==2){
  blocks=c(3:4)
}


filelist=c()
for (s in subjects){
  for (blockNum in blocks){
    filelist=c(filelist,Sys.glob(paste(path, experimentName,"_",s,"_probe_block_0",blockNum,"*.txt",sep="")))
  }
}

probe_data=c()

for (f in filelist){
  probe_data=rbind(probe_data,read.table(f,header=T,na.strings=c(999,999000)))
}


# probe_data$PairType2[probe_data$bidIndexLeft %in% c(7, 10, 12, 13, 8, 9, 11, 14,15, 18, 20, 21, 16, 17, 19, 22)]="HHHA"
# probe_data$PairType2[probe_data$bidIndexLeft %in% c(39, 42, 44, 45, 40, 41, 43, 46,47, 50, 52, 53, 48, 49, 51, 54)]="LLLA"
probe_data$PairType2[probe_data$PairType==1]="High_Value"
probe_data$PairType2[probe_data$PairType==2]="Low_Value"
probe_data$PairType2[probe_data$PairType==4]="Sanity"

probe_data$not_sanity=probe_data$PairType==1|probe_data$PairType==2

# make sure probe data was read correctly
tapply(probe_data$order,probe_data$subjectID,length)
