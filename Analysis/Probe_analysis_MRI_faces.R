# Cue Approach as a General Mechanism for Long Term Non-Reinforced Behavioral Change
# ==================================================================
# Salomon, T., Botvinick-Nezer, R., Gutentag, T., Gera, R., Iwanir, R., Tamir, M., Schonberg, T.

# Instructions: 
# ------------
# 1. Download the data file "probe_data.Rda" or the data file "probe_data_follow_up.Rda". 
# 2. Copy the local path of the data file to 'my_path' variable (line 63); e.g. "~/Downolads/"
# 3. Select the file to be analyzed by uncommenting the appropriate file name to 'my_datafile' variable (lines 65-66)
# 4. If you do not have the 'lme4' and 'ggplot2' packages, install it (type to Consule 'install.packages("lme4")' or 'install.packages("ggplot2")').

# Data file description:
# ---------------------
# In the "probe_data.Rda" file you will find the raw data from the probe phase of ten experiments, and five follow-up sample from Experiments 1-2 and 7-9, 
# described in Salomon et al. (2017). The code analyses the proportion of trials participants chose the Go items over No-GO items using a logistic regression
# with subject's code as a random effect. The analysis indicate significant proportions in comparison to the null hypothesis of 50% chance level (log-odds = 0).
# It also computes 95% CI, and plot the results in a forest plot.

# Data frame variables:
# --------------------

# Variables used in the  analysis:
# "Outcome" - Binary variable indicating whether participant chose the Go item (1) or the NoGo item (0). This is the dependent variable in the logistic regression analysis.
# "subjectID" - Participant's code, is used as a random effect in the logistic regression analysis.
# "PairType" - Categorical veriable indicating the type of comparison:
#       1 - High value: Go vs. NoGo
#       2 - Low value: Go vs. NoGo
#       3 - Sanity Go: High value Go vs. low value Go
#       4 - Sanity NoGo: High value NoGo vs. low value NoGo
# "PairType2" - Same as PairType variable, only as a character class
# Results are analyzed separately for each pair type, or with PairType as a fixed effect to estimate differences of Go choices in high versus low value pairs. 
# "PairType3" - for experiments 1-4, ech category's 8x8 pairs were separeted to two pair-types, each of the higher and lower 4x4 pairs.
# "Experiment" - the experiment number as appearing in Salomon et al. (2017). Each experiment is analyzed separately.     
# "ExperimentName" - description of the experiment's stimuli and cues
# "ExperimentNameFull" - Useful title for each experiment, ordered accordingly to its number

# Other recorded variables:
# "scanner" - Was the experiment conducted in an fMRI settings. All experiments were not.
# "order" - Used to counter-balance Go signal association during training
# "block" - full presentation of all probe choices. Each experiment comprised of two blocks.
# "run" - Each block was split into two runs, for compatibility with fMRI experimental settings.
# "trial" - trial number          
# "onsettime" - Stimuli onset time     
# "ImageLeft" - The name of the stimulus left of the fixation cross      
# "ImageRight"- The name of the stimulus right of the fixation cross     
# "bidLeft" - The initial value of the stimulus left of the fixation cross (as estimate in a BDM or binary ranking task)
# "bidRight" - The initial value of the stimulus right of the fixation cross (as estimate in a BDM or binary ranking task)
# "bidIndexLeft" - The rank-order value of the stimulus left of the fixation cross (range: 1-60)   
# "bidIndexRight" - The rank-order value of the stimulus right of the fixation cross (range: 1-60)
# "IsleftGo" - Binary variable indicating if the left stimulus is Go (1) or No-Go (0). In sanity choices, high value items are indicated similarly to Go items.
# "Response" - participant's choice: "u" - left item, "i" for right items, "x" if subject did not responde on time (RT>1500 ms). When subject responded by choosing 
# the Go item (i.e. IsleftGo==1 & Response=="u", IsleftGo==0 & Response=="i"), the resulting Outcome will be (1).
# "RT" - reaction time.

library("lme4")
library("rstudioapi")    

rm(list=ls())
# Get current path
script_path = rstudioapi::getActiveDocumentContext()$path
pathSplit=strsplit(script_path, "/")
pathSplit=pathSplit[[1]]
main_path=paste0(pathSplit[1:(length(pathSplit)-2)],"/",collapse="")

## Original Sample
path=paste0(main_path,"/Output/")
subjects=c(102,104:114,116:117,119:125,127:141,143:144,146:149); # 42 valid subjects

## Followup
path=paste0(main_path,"/Output/followup/")
subjects=c(102,104:105,108,110:112,114,117,120:123,127,129:131,133:136,138:140,144); # Define here your subjects' codes.

# exclude:
# 101 - had 100% probe choices
# 103 - was too tired during probe and training.
# 115 - clinical MRI findings
# 118 - moved a lot during scans, requested to stop 3 times at training said he was not concentratred.
# 126 - clinical MRI findings
# 142 - minimal ladder
# 145 - poor quality scans
# 151 - clinical MRI findings, Colley ranking, did not finish all scans

# 132 - fell asleep (not excluded)

# Not really excluded:
# 150 - did not run this code

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

exp(HV$coefficients[1]) # HV (in OR)
HV$coefficients[4]*0.5 # p-value (one sided)
exp(HV_CI) # HV Confidence interval (in OR)

exp(LV$coefficients[1]) # LV (in OR)
LV$coefficients[4]*0.5 # p-value (one sided)
exp(LV_CI) # LV Confidence interval (in OR)

summary(glmer(Outcome ~ 1 + PairType + (1|subjectID),data=subset(MRI_faces,MRI_faces$PairType %in% c(1,2)),na.action=na.omit,family=binomial)) #effect of Go choice for HV vs LV
summary(glmer(Outcome ~ 1 + (1|subjectID),data=subset(MRI_faces,MRI_faces$PairType %in% c(1,2)),na.action=na.omit,family=binomial))  #effect of Go choice pooled over both HV vs LV

