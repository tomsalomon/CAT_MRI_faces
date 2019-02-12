
# Dependencies ----

library("rstudioapi")    

# Set Workspace ----

rm(list=ls()) # Clear workspace
script_path = rstudioapi::getActiveDocumentContext()$path # Get current path
pathSplit=strsplit(script_path, "/")
pathSplit=pathSplit[[1]]
# Set the datafile path. Change here if data file is not saved in the same directory as the script; e.g. "~/Downloads/"
current_path = paste0(pathSplit[1:(length(pathSplit)-1)],"/",collapse="") 
main_path = paste0(pathSplit[1:(length(pathSplit)-2)],"/",collapse="") 

# Load Data ----
## Original Sample
path=paste0(main_path,"/Output/")
subjects=c(102,104:114,116:117,119:125,127:141,143:144,146:149); # 42 valid subjects
filelist=c()
for (s in subjects){
  filelist=c(filelist,Sys.glob(paste(path, "MRI_faces_",s,"_probe_block*.txt",sep="")))
}

session_I=c()

for (f in filelist){
  session_I=rbind(session_I,read.table(f,header=T,na.strings=c(999,999000)))
}

## Followup
path=paste0(main_path,"/Output/followup/")
subjects=c(102,104:105,108,110:112,114,117,120:123,127,129:131,133:136,138:140,144); # Define here your subjects' codes.
filelist=c()
for (s in subjects){
  filelist=c(filelist,Sys.glob(paste(path, "MRI_faces_",s,"_probe_block*.txt",sep="")))
}

session_II=c()

for (f in filelist){
  session_II=rbind(session_II,read.table(f,header=T,na.strings=c(999,999000)))
}

session_I$session = 1
session_II$session = 2

probe_data = rbind(session_I,session_II)
probe_data$label = "First Session"
probe_data$label[probe_data$session==2] = "Follow-up"

probe_data$PairType2[probe_data$PairType==1]="High_Value"
probe_data$PairType2[probe_data$PairType==2]="Low_Value"
probe_data$PairType2[probe_data$PairType==4]="Sanity"
write.csv(probe_data,paste0(current_path,"Probe_Data.csv",collapse = ""), row.names = FALSE)
