# create RData file for all participants
library(lme4)
library(rstudioapi)

rm(list=ls())

sessionNum = 1 # 1- session 1 ; 2- follow-up

current_path=dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(current_path)
data_path = './../pre_processed_data/'

# define which subjects to analyze
if (sessionNum==1) {
  subjects=c(102,104:114,116:117,119:125,127:141,143:149)
  scans = c(1,2)
} else if (sessionNum==2) {
  subjects=c(102,104:105,108,110:112,114,117,120:123,127,129:131,133:136,138:140,144)
  scans = 3
}

filelist=c()
for (s in subjects){
  for (scan in scans){
    filelist=c(filelist,Sys.glob(paste0(data_path,"*",s,"*Response*_",scan,".txt")))
  }
}

response_data=c()

for (f in filelist){
  new_data=read.table(f,header=T,na.strings=c(999,999000),sep="\t")
  new_data[,1] = gsub('\t','',new_data[,1])
  order=new_data$order
  if (order==1){
    go_items  =c(7,    10,   12,13,   15,      18,       44,45,   47,      50,   52,53)
    nogo_items=c(  8,9,   11,      14,   16,17,       43,      46,   48,49,   51,      54,    3:6, 19:22, 39:42, 55:58)
  } else {
    go_items  =c(  8,9,   11,      14,   16,17,       43,      46,   48,49,   51,      54)
    nogo_items=c(7,    10,   12,13,   15,      18,       44,45,   47,      50,   52,53,       3:6, 19:22, 39:42, 55:58)    
  }
  new_data$isGo=new_data$bidInd %in% go_items
  new_data$ishv=new_data$bidInd %in% c(1:30)
  new_data$isinprobe=new_data$bidInd %in% c(7:18,43:54)
  response_data=rbind(response_data,new_data)
}

# make sure probe data was read correctly
as.data.frame(tapply(response_data$order,response_data$subjectID,length))
filename=paste0("./Response_data_session_",sessionNum,".Rda")
save(response_data,file=filename)
