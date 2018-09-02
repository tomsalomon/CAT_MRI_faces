rm(list=ls())

# define session and group
group = 1 # 1- study 2 - control
sessionNum = 1 # 2- followup

# define which subjects
if (group==1 & sessionNum==1) {
  subjects=c(126:128, 130, 132:134, 137, 139:141) # study group session 1
  experimentName = "MRI_snacks"
} else if (group==2 & sessionNum==1) {
  subjects=c(123, 125:126, 128:129, 131:133, 135, 137:140) # control group session 1
  experimentName = "MRI_snacks2"
} else if (group==1 & sessionNum==2) {
  subjects=c(125:128, 132:135, 138, 140) # study group follow up
  experimentName = "MRI_snacks"
} else if (group==2 & sessionNum==2) {
  subjects=c(123, 129, 131, 135) # control group follow up
  experimentName = "MRI_snacks2"
}

runs=1:2

load(paste("/Users/rotembotvinik/Google_Drive/my_research/Analysis/behavior/",experimentName,"_session",sessionNum,"_responseToSnacks_data.Rda",sep="")) #this is my compiled probe RData file for all participants in this group and session
num_participants=length(unique(responsetosnacks_data$subjectID))
print(paste("session num ", sessionNum))
print(group)
print(paste("num participants in this response to snacks data is: ", num_participants,sep=""))

library(gdata)
#responsetosnacks=responsetosnacks_data
#responsetosnacks$go_stim_look_tot=NA
#responsetosnacks$go_stim_not_look_tot=NA
#responsetosnacks$nogo_stim_look_tot=NA
#responsetosnacks$nogo_stim_not_look_tot=NA
#responsetosnacks$hv_stim_look_tot=NA
#responsetosnacks$hv_stim_not_look_tot=NA
#responsetosnacks$lv_stim_look_tot=NA
#responsetosnacks$lv_stim_not_look_tot=NA
#responsetosnacks$hvgo_stim_look_tot=NA
#responsetosnacks$hvgo_stim_not_look_tot=NA
#responsetosnacks$hvnogo_stim_look_tot=NA
#responsetosnacks$hvnogo_stim_not_look_tot=NA
#responsetosnacks$lvgo_stim_look_tot=NA
#responsetosnacks$lvgo_stim_not_look_tot=NA
#responsetosnacks$lvnogo_stim_look_tot=NA
#responsetosnacks$lvnogo_stim_not_look_tot=NA
#responsetosnacks$isi_look_tot=NA
#responsetosnacks$isi_not_look_tot=NA


path="/Users/rotembotvinik/Google_Drive/my_research/experiments/BMI_MRI_snacks_40/BMI_MRI_snacks_40/Output/"
output_path="/Users/rotembotvinik/Google_Drive/my_research/Analysis/eyetracker/"

ind_sub=1
for (subject in subjects){ 
  sub=paste(experimentName, "_",subject, sep="")
  print(sub)
  blocks=c("before","after")
  for (b in blocks){
  	for (r in runs){
  		filelist=Sys.glob(paste(path,sub,"_responseToSnacks_session",sessionNum,"_", b,"_run",r,"_eyetrack.txt",sep="")) #this is the processed eyetracker txt generated with accompanying R file
  		if (length(filelist)<1) next
  		print(paste("block ",b,sep=""))
  		print(paste("run num ",r,sep=""))
  		eyetracking_data=read.table(filelist,header=T) 
  		#total time spent L/M/R per phase
  		eyetracking_data$islooking=eyetracking_data$looking=="stim"
  		eyetracking_data$islooking[is.na(eyetracking_data$islooking)]=FALSE
  		eyetracking_data$goprobe=eyetracking_data$isgoitem & eyetracking_data$isprobeitem
  		eyetracking_data$nogoprobe=!eyetracking_data$isgoitem & eyetracking_data$isprobeitem
  		eyetracking_data$itemtype[eyetracking_data$isgoitem & eyetracking_data$isprobeitem & eyetracking_data$ishvitem]="hvgo"
  		eyetracking_data$itemtype[eyetracking_data$isgoitem & eyetracking_data$isprobeitem & !eyetracking_data$ishvitem]="lvgo"
  		eyetracking_data$itemtype[!eyetracking_data$isgoitem & eyetracking_data$isprobeitem & eyetracking_data$ishvitem]="hvnogo"
  		eyetracking_data$itemtype[!eyetracking_data$isgoitem & eyetracking_data$isprobeitem & !eyetracking_data$ishvitem]="lvnogo"
  		
  		# calculate percent time viewing
  		time_go_stim_presented=sum(eyetracking_data$phase=="item_presented" & eyetracking_data$goprobe, na.rm =TRUE)*eyetracking_data$add[1]
  		time_hv_go_stim_presented=sum(eyetracking_data$phase=="item_presented" & eyetracking_data$itemtype=="hvgo", na.rm =TRUE)*eyetracking_data$add[1]
  		time_lv_go_stim_presented=sum(eyetracking_data$phase=="item_presented" & eyetracking_data$itemtype=="lvgo", na.rm =TRUE)*eyetracking_data$add[1]
  		time_nogo_stim_presented=sum(eyetracking_data$phase=="item_presented" & eyetracking_data$nogoprobe, na.rm =TRUE)*eyetracking_data$add[1]
  		time_hv_nogo_stim_presented=sum(eyetracking_data$phase=="item_presented" & eyetracking_data$itemtype=="hvnogo", na.rm =TRUE)*eyetracking_data$add[1]
  		time_lv_nogo_stim_presented=sum(eyetracking_data$phase=="item_presented" & eyetracking_data$itemtype=="lvnogo", na.rm =TRUE)*eyetracking_data$add[1]
  		time_looking_on_go=sum(eyetracking_data$islooking[eyetracking_data$phase=="item_presented" & eyetracking_data$goprobe],na.rm =TRUE)*eyetracking_data$add[1]
  		time_looking_on_hv_go=sum(eyetracking_data$islooking[eyetracking_data$phase=="item_presented" & eyetracking_data$itemtype=="hvgo"],na.rm =TRUE)*eyetracking_data$add[1]
  		time_looking_on_lv_go=sum(eyetracking_data$islooking[eyetracking_data$phase=="item_presented" & eyetracking_data$itemtype=="lvgo"],na.rm =TRUE)*eyetracking_data$add[1]
  		time_looking_on_nogo=sum(eyetracking_data$islooking[eyetracking_data$phase=="item_presented" & eyetracking_data$nogoprobe],na.rm =TRUE)*eyetracking_data$add[1]
  		time_looking_on_hv_nogo=sum(eyetracking_data$islooking[eyetracking_data$phase=="item_presented" & eyetracking_data$itemtype=="hvnogo"],na.rm =TRUE)*eyetracking_data$add[1]
  		time_looking_on_lv_nogo=sum(eyetracking_data$islooking[eyetracking_data$phase=="item_presented" & eyetracking_data$itemtype=="lvnogo"],na.rm =TRUE)*eyetracking_data$add[1]
  		percent_looking_on_go=time_looking_on_go/time_go_stim_presented*100
  		percent_looking_on_hv_go=time_looking_on_hv_go/time_hv_go_stim_presented*100
  		percent_looking_on_lv_go=time_looking_on_lv_go/time_lv_go_stim_presented*100
  		percent_looking_on_nogo=time_looking_on_nogo/time_nogo_stim_presented*100
  		percent_looking_on_hv_nogo=time_looking_on_hv_nogo/time_hv_nogo_stim_presented*100
  		percent_looking_on_lv_nogo=time_looking_on_lv_nogo/time_lv_nogo_stim_presented*100
  		total_time_blinks=sum(eyetracking_data$event=="blink",na.rm = TRUE)*eyetracking_data$add[1]
  		total_time_blinks_go=sum(eyetracking_data$event[eyetracking_data$goprobe]=="blink",na.rm = TRUE)*eyetracking_data$add[1]
  		total_time_blinks_hv_go=sum(eyetracking_data$event[eyetracking_data$itemtype=="hvgo"]=="blink",na.rm = TRUE)*eyetracking_data$add[1]
  		total_time_blinks_lv_go=sum(eyetracking_data$event[eyetracking_data$itemtype=="lvgo"]=="blink",na.rm = TRUE)*eyetracking_data$add[1]
  		total_time_blinks_nogo=sum(eyetracking_data$event[eyetracking_data$nogoprobe]=="blink",na.rm = TRUE)*eyetracking_data$add[1]
  		total_time_blinks_hv_nogo=sum(eyetracking_data$event[eyetracking_data$itemtype=="hvnogo"]=="blink",na.rm = TRUE)*eyetracking_data$add[1]
  		total_time_blinks_lv_nogo=sum(eyetracking_data$event[eyetracking_data$itemtype=="lvnogo"]=="blink",na.rm = TRUE)*eyetracking_data$add[1]
  		
  		time_point=b
  		run_num=r
  		summary_viewing_time_curr_subject=data.frame(sub,sessionNum,time_point,run_num,time_go_stim_presented,time_hv_go_stim_presented,time_lv_go_stim_presented,time_nogo_stim_presented,time_hv_nogo_stim_presented,time_lv_nogo_stim_presented,time_looking_on_go,time_looking_on_hv_go,time_looking_on_lv_go,time_looking_on_nogo,time_looking_on_hv_nogo,time_looking_on_lv_nogo,percent_looking_on_go,percent_looking_on_hv_go,percent_looking_on_lv_go,percent_looking_on_nogo,percent_looking_on_hv_nogo,percent_looking_on_lv_nogo,total_time_blinks,total_time_blinks_go,total_time_blinks_hv_go,total_time_blinks_lv_go,total_time_blinks_nogo,total_time_blinks_hv_nogo,total_time_blinks_lv_nogo)
  		if (ind_sub==1){
  		summary_viewing_time=data.frame(summary_viewing_time_curr_subject)
  	}else{
  	  summary_viewing_time=rbind(summary_viewing_time,summary_viewing_time_curr_subject)
  	}
  		ind_sub=ind_sub+1
  	}
  }
}

if (sessionNum==1){
  session="session1"
}else{
  session="followup"
}
save(summary_viewing_time,file=paste(output_path,experimentName,"_",session,"_responsetosnacks_summary_viewing.RData",sep=""))