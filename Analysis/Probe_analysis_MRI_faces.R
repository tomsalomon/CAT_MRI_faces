
library(lme4)

rm(list=ls())

## Original Sample
#For iMac
path="~/Drive/Experiment_Israel/Codes/MRI_faces/Output/"
## For PC
#path="C:/Users/Tom/Dropbox/Experiment_Israel/Codes/MRI_faces/Output/"

# subjects=c(101:102,104:114,116:117,119:125,127:144); # Define here your subjects' codes.
subjects=c(102,104:114,116:117,119:125,127:141,143:149); # 43 valid subjects


# exclude:
# 101 - had 100% probe choices
# 103 - was too tired during probe and training.
# 115 - clinical MRI findings
# 118 - moved a lot during scans, requested to stop 3 times at training said he was not concentratred.
# 126 - clinical MRI findings
# 142 - minimal ladder
# 151 - clinical MRI findings, Colley ranking, did not finish all scans

# 132 - fell asleep (not excluded)

# Not really excluded:
# 150 - did not run this code

## Followup
#For iMac
path="~/Drive/Experiment_Israel/Codes/MRI_faces/Output/followup/"
# For PC
# path="C:/Users/Tom/Dropbox/Experiment_Israel/Codes/MRI_faces/Output/followup/"

# subjects=c(102,104:105,107:108,110:112,114,117,120:123,127,129:136,138:140); # Define here your subjects' codes.
subjects=c(102,104:105,108,110:112,114,117,120:123,127,129:131,133:136,138:140,144); # Define here your subjects' codes.


filelist=c()
for (s in subjects){
	filelist=c(filelist,Sys.glob(paste(path, "MRI_faces_",s,"_probe_block*.txt",sep="")))
}

MRI_faces=c()

for (f in filelist){
	MRI_faces=rbind(MRI_faces,read.table(f,header=T,na.strings=c(999,999000)))
}

MRI_faces$PairType2[MRI_faces$PairType==1]="High_Value"
MRI_faces$PairType2[MRI_faces$PairType==2]="Low_Value"
MRI_faces$PairType2[MRI_faces$PairType==4]="Sanity"

tapply(MRI_faces$Outcome,MRI_faces$PairType2,mean,na.rm=T)

summary(glmer(Outcome ~ 1 + (1|subjectID),data=subset(MRI_faces,(MRI_faces$PairType2=='High_Value')),na.action=na.omit,family=binomial)) 
summary(glmer(Outcome ~ 1 + (1|subjectID),data=subset(MRI_faces,(MRI_faces$PairType2=='Low_Value')),na.action=na.omit,family=binomial))

HV=summary(glmer(Outcome ~ 1 + (1|subjectID),data=subset(MRI_faces,(MRI_faces$PairType2=='High_Value')),na.action=na.omit,family=binomial)) 
LV=summary(glmer(Outcome ~ 1 + (1|subjectID),data=subset(MRI_faces,(MRI_faces$PairType2=='Low_Value')),na.action=na.omit,family=binomial))

HV_CI=c(HV$coefficients[1]-1.96*HV$coefficients[2],HV$coefficients[1]+1.96*HV$coefficients[2]) # HV Confidence interval (in log odds)
LV_CI=c(LV$coefficients[1]-1.96*LV$coefficients[2],LV$coefficients[1]+1.96*LV$coefficients[2]) # LV Confidence interval (in log odds)
exp(HV_CI)/(1+exp(HV_CI)) # HV Confidence interval (in proportions)
exp(LV_CI)/(1+exp(LV_CI)) # LV Confidence interval (in proportions)



summary(glmer(Outcome ~ 1 + PairType + (1|subjectID),data=subset(MRI_faces,MRI_faces$PairType %in% c(1,2)),na.action=na.omit,family=binomial)) #effect of Go choice for HH vs LL
summary(glmer(Outcome ~ 1 + (1|subjectID),data=subset(MRI_faces,MRI_faces$PairType %in% c(1,2)),na.action=na.omit,family=binomial)) #effect of Go choice for HH vs LL

