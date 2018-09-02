rm(list=ls())

library(lme4)
library(lmer)
library(lmerTest)

# define session and group
group = 1 # 1- study 2 - control
sessionNum = 2 # 2- followup

# define which subjects
if (group==1 & sessionNum==1) {
  subjects=c(126:127, 130, 132:134, 137, 139:141) # study group session 1
  # for some data for mri_snacks_128 is corrupted, so I removed him/her from here
  experimentName = "MRI_snacks"
  session="session1"
} else if (group==2 & sessionNum==1) {
  subjects=c(123, 125:126, 128:129, 131:133, 135, 137:140) # control group session 1
  experimentName = "MRI_snacks2"
  session="session1"
} else if (group==1 & sessionNum==2) {
  subjects=c(125:128, 132:135, 138, 140) # study group follow up
  experimentName = "MRI_snacks"
  session="followup"
} else if (group==2 & sessionNum==2) {
  subjects=c(123, 129, 131, 135) # control group follow up
  experimentName = "MRI_snacks2"
  session="followup"
}

# load the data and prepare for the analysis
path="/Users/rotembotvinik/Google_Drive/my_research/Analysis/eyetracker/"
load(paste(path,experimentName,"_",session,"_responsetosnacks_summary_viewing.Rdata",sep=""))
summary_viewing_time=aggregate(summary_viewing_time,by=list(summary_viewing_time$sub),FUN=mean)
percent_viewing_gonogo=summary_viewing_time[,c(18,21)]
percent_viewing_gonogohvlv=summary_viewing_time[,c(19:20,22:23)]
means_gonogo=colMeans(percent_viewing_gonogo)
means_gonogohvlv=colMeans(percent_viewing_gonogohvlv)

# plot viewing time by item type
layout(matrix(c(2,1),2,1))
boxplot(percent_viewing_gonogo,names=c("Go","NoGo"),ylab="percent viewing time")
points(1:2,means_gonogo)
boxplot(percent_viewing_gonogohvlv,names=c("HV Go","LV Go", "HV NoGo", "LV NoGo"),ylab="percent viewing time",las=2)
points(1:4,means_gonogohvlv)

print(paste("num of participants: ", length(subjects),sep=""))
print(paste("group: ",experimentName,sep=""))
print(paste("session: ", session, sep=""))
print("means:")
print(paste("mean", list("go","nogo"),means_gonogo))
print(paste("mean",list("hvgo","lvgo","hvnogo","lvnogo"), means_gonogohvlv, sep=" "))

print('t-test all Go vs. NoGo')
t.test(summary_viewing_time$percent_looking_on_go,summary_viewing_time$percent_looking_on_nogo,paired = TRUE)

print('t-test HV Go vs. NoGo')
t.test(summary_viewing_time$percent_looking_on_hv_go,summary_viewing_time$percent_looking_on_hv_nogo,paired = TRUE)


### NOT READY FROM HERE AND MAYBE BEFORE

# predict probe effect by viewing time
print("predict probe effect by viewing time")

# load probe data
behavior_path="/Users/rotembotvinik/Google_Drive/my_research/Analysis/behavior/"
load(paste(behavior_path,experimentName,'_', session, '_probe_data.Rda', sep=""))
subjects_str=paste("MRI_snacks_",subjects,sep="")
probe_data_sub_sample=probe_data[(probe_data$subjectID %in% subjects_str),]
probe_results=tapply(probe_data_sub_sample$Outcome,list(probe_data_sub_sample$subjectID,probe_data_sub_sample$PairType2),mean,na.rm=T)
probe_results=na.omit(probe_results)
probe_results=as.data.frame(probe_results)

print("probe HV by viewing hv go minus hv nogo")
probe_results$view_diff_hvgo_minus_hvnogo=percent_viewing_gonogohvlv$percent_looking_on_hv_go-percent_viewing_gonogohvlv$percent_looking_on_hv_nogo
summary(lmer(High_Value ~ view_diff_hvgo_minus_hvnogo + (1|subjectID),data=probe_data_sub_sample,na.action=na.omit)) 

print("probe LV by viewing lv go minus lv nogo")
view_diff_lvgo_minus_lvnogo=percent_viewing_gonogohvlv$percent_looking_on_lv_go-percent_viewing_gonogohvlv$percent_looking_on_lv_nogo