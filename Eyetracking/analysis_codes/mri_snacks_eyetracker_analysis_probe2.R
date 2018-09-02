rm(list=ls())

# define session and group
group = 1 # 1- study 2 - control
sessionNum = 1 # 2- followup

# define which subjects
if (group==1 & sessionNum==1) {
  subjects=c(126, 127:128, 130, 132:134, 137, 139:140) # study group session 1
  experimentName = "MRI_snacks"
  blocks=1:2
  session="session1"
} else if (group==2 & sessionNum==1) {
  subjects=c(123, 125, 128:129, 131:133, 135, 137:138, 140) # control group session 1
  experimentName = "MRI_snacks2"
  blocks=1:2
  session="session1"
} else if (group==1 & sessionNum==2) {
  subjects=c(124:128, 132:135, 138, 140) # study group follow up
  experimentName = "MRI_snacks"
  blocks=3:4
  session="followup"
} else if (group==2 & sessionNum==2) {
  subjects=c(123, 129, 131, 135) # control group follow up
  experimentName = "MRI_snacks2"
  blocks=3:4
  session="followup"
}

runs=1:2

load(paste("/Users/rotembotvinik/Google_Drive/my_research/Analysis/behavior/",experimentName,"_",session,"_probe_data.Rda",sep="")) #this is my compiled probe RData file for all participants in this group and session
num_participants=length(unique(probe_data$subjectID))
print(session)
print(group)
print(paste("num participants in this probe data is: ", num_participants,sep=""))

library(gdata)
probe=probe_data
probe$choice_left_tot=NA
probe$choice_middle_tot=NA
probe$choice_right_tot=NA
probe$confirm_left_tot=NA
probe$comfirm_middle_tot=NA
probe$confirm_right_tot=NA
probe$isi_left_tot=NA
probe$isi_middle_tot=NA
probe$isi_right_tot=NA
probe$choice_left_fixnum=NA
probe$choice_middle_fixnum=NA
probe$choice_right_fixnum=NA
probe$confirm_left_fixnum=NA
probe$comfirm_middle_fixnum=NA
probe$confirm_right_fixnum=NA
probe$isi_left_fixnum=NA
probe$isi_middle_fixnum=NA
probe$isi_right_fixnum=NA
#train$subjid=drop.levels(train$subjid)

path="/Users/rotembotvinik/Google_Drive/my_research/experiments/BMI_MRI_snacks_40/BMI_MRI_snacks_40/Output/"
output_path="/Users/rotembotvinik/Google_Drive/my_research/Analysis/eyetracker/"

for (subject in subjects){ 
  sub=paste(experimentName, "_",subject, sep="")
  print(sub)
  for (b in blocks){
  	for (r in runs){
  		print(paste("block num ",b,sep=""))
  	  print(paste("run num ",r,sep=""))
  		filelist=Sys.glob(paste(path,sub,"_probe_block", b,"_run",r,"_eyetrack.txt",sep="")) #this is the processed eyetracker txt generated with accompanying R file
  		if (length(filelist)<1) next
  		eyetracking_data=read.table(filelist,header=T) 
  		#total time spent L/M/R per phase
  		
  		total=tapply(eyetracking_data$add,list(eyetracking_data$trial,eyetracking_data$looking,eyetracking_data$phase),sum)	#summary viewing time by left/mid/right by trial phase for each trial
  		total[is.na(total)]=0
  
  		#total time viewing left/mid/right during choice phase
  		probe$choice_left_tot[probe$subjectID==sub & probe$run == r]=total[,2,1]
  		probe$choice_middle_tot[probe$subjectID==sub & probe$run == r]=total[,1,1]
  		probe$choice_right_tot[probe$subjectID==sub & probe$run == r]=total[,3,1]
  		#total time viewing left/mid/right during choice confirmation phase
  		probe$confirm_left_tot[probe$subjectID==sub & probe$run == r]=total[,2,2]
  		probe$comfirm_middle_tot[probe$subjectID==sub & probe$run == r]=total[,1,2]
  		probe$confirm_right_tot[probe$subjectID==sub & probe$run == r]=total[,3,2]
  		#total time viewing left/mid/right during ISI phase
  		probe$isi_left_tot[probe$subjectID==sub & probe$run == r]=total[,2,3]
  		probe$isi_middle_tot[probe$subjectID==sub & probe$run == r]=total[,1,3]
  		probe$isi_right_tot[probe$subjectID==sub & probe$run == r]=total[,3,3]
  
  
  		fix=subset(eyetracking_data,eyetracking_data$event=="fix")
  		fixnum=tapply(fix$eventnumber,list(fix$trial,fix$looking,fix$phase),max)-(tapply(fix$eventnumber,list(fix$trial,fix$looking,fix$phase),min)-1)
  		fixnum[is.na(fixnum)]=0
  
  		#total number of fixations left/mid/right during choice phase
  		probe$choice_left_fixnum[probe$subjectID==sub & probe$run == r]=fixnum[,2,1]
  		probe$choice_middle_fixnum[probe$subjectID==sub & probe$run == r]=fixnum[,1,1]
  		probe$choice_right_fixnum[probe$subjectID==sub & probe$run == r]=fixnum[,3,1]
  		#total number of fixations left/mid/right during choice confirmation phase
  		probe$confirm_left_fixnum[probe$subjectID==sub & probe$run == r]=fixnum[,2,2]
  		probe$comfirm_middle_fixnum[probe$subjectID==sub & probe$run == r]=fixnum[,1,2]
  		probe$confirm_right_fixnum[probe$subjectID==sub & probe$run == r]=fixnum[,3,2]
  		#total number of fixations left/mid/right during ISI phase
  		probe$isi_left_fixnum[probe$subjectID==sub & probe$run == r]=fixnum[,2,3]
  		probe$isi_middle_fixnum[probe$subjectID==sub & probe$run == r]=fixnum[,1,3]
  		probe$isi_right_fixnum[probe$subjectID==sub & probe$run == r]=fixnum[,3,3]
  		
  	}	
  }
}

probe_gaze=probe[complete.cases(probe),]

save(probe_gaze,file=paste(output_path,experimentName,"_",session,"_probe_gaze.RData",sep=""))