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

blocks=c("before","after")

filelist=c()
for (s in subjects){
  for (block in blocks){
    filelist=c(filelist,Sys.glob(paste(path, experimentName,"_",s,"_responseToSnacks_session",sessionNum,"*m.txt",sep="")))
  }
}

responsetosnacks_data=c()

for (f in filelist){
  new_data=read.table(f,header=T,na.strings=c(999,999000))
  colnames(new_data)[8]="oneOrSeveral"
  #sub_num=str_sub(new_data$subjectID[1],-3,-1)
  #is_odd=sub_num%%2 # 1 for subjects with order=1; 0 for order=2
  order=new_data$order
  if (order==1){
    go_items=c(7,10,12,13,15,18,44,45,47,50,52,53)
    nogo_items=c(8,9,11,14,16,17,43,46,48,49,51,54, 3:6, 19:22, 39:42, 55:58)
  } else {
    go_items=c(8,9,11,14,16,17,43,46,48,49,51,54)
    nogo_items=c(7,10,12,13,15,18,44,45,47,50,52,53, 3:6, 19:22, 39:42, 55:58)    
  }
  new_data$isGo=new_data$bidInd %in% go_items
  new_data$ishv=new_data$bidInd %in% c(1:30)
  new_data$isinprobe=new_data$bidInd %in% c(7:18,43:54)
  responsetosnacks_data=rbind(responsetosnacks_data,new_data)
}



# make sure probe data was read correctly
tapply(responsetosnacks_data$order,responsetosnacks_data$subjectID,length)

path="/Users/rotembotvinik/Google_Drive/my_research/Analysis/behavior"
filename=paste(path,"/",experimentName,"_session",sessionNum,"_responseToSnacks_data.Rda",sep="")
save(responsetosnacks_data,file=filename)
