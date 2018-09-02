library(stringr)
rm(list=ls())

group = 1 # 1- study 2 - control
sessionNum = 1 # 2- followup

# define which subjects
if (group==1 & sessionNum==1) {
  subjects=c(126:127, 130, 132:134, 137, 139:141) # study group session 1
  # for some data for mri_snacks_128 is corrupted, so I removed him/her from here
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

path="/Users/rotembotvinik/Google_Drive/my_research/experiments/BMI_MRI_snacks_40/BMI_MRI_snacks_40/Output/"

numtrials=40 # num trials per run

for (s in subjects){
  
  subject=paste(experimentName, "_",s, sep="")
  blocks=c("before","after")
  
  # check the order of the participants and classify items to go/nogo in accordance
  is_odd=s%%2 # 1 for subjects with order=1; 0 for order=2
  if (is_odd){
    go_items=c(7,10,12,13,15,18,44,45,47,50,52,53)
    nogo_items=c(8,9,11,14,16,17,43,46,48,49,51,54, 3:6, 19:22, 39:42, 55:58)
  } else {
    go_items=c(8,9,11,14,16,17,43,46,48,49,51,54)
    nogo_items=c(7,10,12,13,15,18,44,45,47,50,52,53, 3:6, 19:22, 39:42, 55:58)    
  }
  
  for (b in blocks){
    for (run_num in runs){
      eyetracking_filelist=Sys.glob(paste(path,subject,"_resopnseToSnacks_EyeTracking_session_",sessionNum,"_",b,"_run_", run_num,"*.asc",sep=""))
      if (length(eyetracking_filelist)<1) next
      filename=eyetracking_filelist[1]
      time_stamp=str_sub(filename,-22,-5)
      behavior_filelist=Sys.glob(paste(path,subject,"_responseToSnacks_session",sessionNum,"_",b,"*",time_stamp,".txt",sep=""))
      
      if(length(eyetracking_filelist)!=0 & length(behavior_filelist)!=0){
        
        print(paste("processing subject ", subject, " responsetosnacks session", sessionNum, b, " run ", run_num, " ... "))
        
        responsetosnacks_data=c()
        
        # read response to snacks data
        for (f in behavior_filelist){
          responsetosnacks_data=rbind(responsetosnacks_data,read.table(f,header=T,na.strings=c(999,999000)))
        }
        
        responsetosnacks_data$isGo=responsetosnacks_data$bidInd %in% go_items
        responsetosnacks_data$ishv=responsetosnacks_data$bidInd %in% c(1:30)
        responsetosnacks_data$isinprobe=responsetosnacks_data$bidInd %in% c(7:18,43:54)
          
        # read eyetracking data
        input<- readLines(eyetracking_filelist)
        
        l=c()
        
        options(warn=-1)
        
        #don't want header, figure out the first line that is not header
        for (i in 1:2000){
          
          if (is.null(l) & is.na(as.numeric(strsplit(input[i],"\t")[[1]][1]))==FALSE){
            firstline=i
            l=rbind(l,input[firstline])
          }
        }
        
        exclude=c(grep("MSG",input[firstline:length(input)]),grep("SFIX",input[firstline:length(input)]),grep("EFIX",input[firstline:length(input)]),grep("SSACC",input[firstline:length(input)]),grep("ESACC",input[firstline:length(input)]),grep("SBLINK",input[firstline:length(input)]),grep("EBLINK",input[firstline:length(input)]),grep("SAMPLES",input[firstline:length(input)]),grep("INPUT",input[firstline:length(input)]))
        
        eyetracking_data=input[firstline:length(input)][!1:length(input[firstline:length(input)]) %in% exclude]
        
        
        #eyetracking_data=structure(data.frame(matrix(unlist(strsplit(eyetracking_data,"\t")),length(eyetracking_data),9,T)),  names=c("time","x","y","pupil","phase","xv","yv","rez","V1"))
        #eyetracking_data=structure(data.frame(matrix(unlist(strsplit(eyetracking_data,"\t")),length(eyetracking_data),8,T)),  names=c("time","x","y","pupil","phase","xv","yv","rez"))
        eyetracking_data=structure(data.frame(matrix(unlist(strsplit(eyetracking_data,"\t")),length(eyetracking_data),6,T)),  names=c("time","x","y","pupil","V1","phase"))
        #eyetracking_data=structure(data.frame(matrix(unlist(strsplit(eyetracking_data,"\t")),length(eyetracking_data),5,T)),  names=c("time","x","y","pupil","phase"))
        
        eyetracking_data$time=as.numeric(as.character(eyetracking_data$time))
        eyetracking_data$trial=rep(NA,length(eyetracking_data$time))
        eyetracking_data$phase=NA
        eyetracking_data$x=as.numeric(as.character(eyetracking_data$x))
        eyetracking_data$y=as.numeric(as.character(eyetracking_data$y))
        eyetracking_data$pupil=as.numeric(as.character(eyetracking_data$pupil))
        
        # get the frequency
        freq=1000/(eyetracking_data$time[2]-eyetracking_data$time[1])
        
        # get the eye-tracker time of the run start. We wil count from it according to the behavioral data to parse the eye-tracking data into choice/confirmation/fixation
        run_start=structure(data.frame( matrix(unlist(strsplit(input[grep("SYNCTIME",input)],"\t|\ |\\=")),length(input[grep("SYNCTIME",input)]),6,T)),  names=c("msg","time","synctime","at","run start:","computertime")) 
        run_start_time=run_start$time=as.numeric(as.character(run_start$time))
        
        ssacc=structure(data.frame( matrix(unlist(strsplit(input[grep("SSACC",input)],"\ ")),length(input[grep("SSACC",input)]),4,T)),  names=c("event","filler","empty","time")) 
        ssacc$time=as.numeric(as.character(ssacc$time))
        esacc=structure(data.frame( matrix(unlist(strsplit(input[grep("ESACC",input)],"\t")),length(input[grep("ESACC",input)]),15,T)),  names=c("event","time","duration","startx","starty","endx","endy","amplitude","velocity","startx2","starty2","endx2","endy2","amplitude2","velocity2")) 
        esacc$time=as.numeric(as.character(esacc$time))
        sfix=structure(data.frame( matrix(unlist(strsplit(input[grep("SFIX",input)],"\ ")),length(input[grep("SFIX",input)]),5,T)),  names=c("event","filler","e1","e2","time")) 
        sfix$time=as.numeric(as.character(sfix$time))
        efix=structure(data.frame( matrix(unlist(strsplit(input[grep("EFIX",input)],"\t")),length(input[grep("EFIX",input)]),9,T)),  names=c("event","time","duration","x","y","pupil","x2","y2","pupil2")) 
        efix$time=sort(as.numeric(levels(efix$time)))
        sblink=structure(data.frame( matrix(unlist(strsplit(input[grep("SBLINK",input)],"\ ")),length(input[grep("SBLINK",input)]),3,T)),  names=c("event","filler","time")) 
        sblink$time=as.numeric(as.character(sblink$time))
        eblink=structure(data.frame( matrix(unlist(strsplit(input[grep("EBLINK",input)],"\t")),length(input[grep("EBLINK",input)]),3,T)),  names=c("event","time","duration")) 
        eblink$time=as.numeric(as.character(eblink$time))
        
        eyetracking_data$trial=rep(NA,length(eyetracking_data$time))
        eyetracking_data$phase=rep(NA,length(eyetracking_data$time))
        eyetracking_data$block=b
        eyetracking_data$run=run_num
        eyetracking_data$session=sessionNum
        eyetracking_data$isgoitem=NA
        eyetracking_data$ishvitem=NA
        eyetracking_data$isprobeitem=NA
        
        # calculate times of trial start
        trial_start_times=run_start_time+(responsetosnacks_data$onsettime*1000)
        trial_start_times=round(trial_start_times) # onsettimes from the behavioral files are not round
        # calculate times of trial start
        fixation_times=run_start_time+(responsetosnacks_data$fixationTime*1000)
        fixation_times=round(fixation_times)
        
        # classify lines in eyetracking_data to choice/confirmation/fixation
        for (i in 1:numtrials){
          if (freq==250){
            s1=which(eyetracking_data$time==trial_start_times[i] | eyetracking_data$time==trial_start_times[i]+1 | eyetracking_data$time==trial_start_times[i]+2 | eyetracking_data$time==trial_start_times[i]+3)
            e1=which(eyetracking_data$time==fixation_times[i] | eyetracking_data$time==fixation_times[i]-1 | eyetracking_data$time==fixation_times[i]-2 | eyetracking_data$time==fixation_times[i]-3)
            s2=which(eyetracking_data$time==fixation_times[i] | eyetracking_data$time==fixation_times[i]+1 | eyetracking_data$time==fixation_times[i]+2 | eyetracking_data$time==fixation_times[i]+3)
            if(length(s2)==0){s2=length(eyetracking_data$time)}
            if (i<numtrials){
              e2=which(eyetracking_data$time==trial_start_times[i+1] | eyetracking_data$time==trial_start_times[i+1]-1 | eyetracking_data$time==trial_start_times[i+1]-2 | eyetracking_data$time==trial_start_times[i+1]-3)
            }else{
              e2=length(eyetracking_data$time)
            }
          }else if (freq==500){
            s1=which(eyetracking_data$time==trial_start_times[i] | eyetracking_data$time==trial_start_times[i]+1)
            e1=which(eyetracking_data$time==fixation_times[i] | eyetracking_data$time==fixation_times[i]-1)
            s2=which(eyetracking_data$time==fixation_times[i] | eyetracking_data$time==fixation_times[i]+1)
            if(length(s2)==0){s2=length(eyetracking_data$time)}
            if (i<numtrials){
              e2=which(eyetracking_data$time==trial_start_times[i+1] | eyetracking_data$time==trial_start_times[i+1]-1)
            }else{
              e2=length(eyetracking_data$time)
            }
          }else if (freq==1000){
            s1=which(eyetracking_data$time==trial_start_times[i])
            e1=which(eyetracking_data$time==fixation_times[i])
            s2=which(eyetracking_data$time==fixation_times[i])
            if(length(s2)==0){s2=length(eyetracking_data$time)}
            if (i<numtrials){
              e2=which(eyetracking_data$time==trial_start_times[i+1])
            }else{
              e2=length(eyetracking_data$time)
            }
          }
          
          eyetracking_data$phase[s1:e1]="item_presented"
          eyetracking_data$isgoitem[s1:e1]=responsetosnacks_data$isGo[i]
          eyetracking_data$ishvitem[s1:e1]=responsetosnacks_data$ishv[i]
          eyetracking_data$isprobeitem[s1:e1]=responsetosnacks_data$isinprobe[i]
          eyetracking_data$phase[s2:e2]="fixation"
          eyetracking_data$trial[s1:e2]=i
          eyetracking_data$block[s1:e2]=b
          eyetracking_data$run[s1:e2]=run_num
          eyetracking_data$session[s1:e2]=sessionNum
        }
        
        
        eyetracking_data$event=NA
        eyetracking_data$eventnumber=NA
        for(i in 1:length(ssacc$event)){
          if (freq==250){
            s=which(eyetracking_data$time==ssacc$time[i] | eyetracking_data$time==ssacc$time[i]+1 | eyetracking_data$time==ssacc$time[i]+2 | eyetracking_data$time==ssacc$time[i]+3)
            if ( i <= length (esacc$time)){
              e=which(eyetracking_data$time==esacc$time[i] | eyetracking_data$time==esacc$time[i]-1 | eyetracking_data$time==esacc$time[i]-2 | eyetracking_data$time==esacc$time[i]-3)
            }
            else {
              e=length(eyetracking_data$event)
            }
          }else if (freq==500){
            s=which(eyetracking_data$time==ssacc$time[i] | eyetracking_data$time==ssacc$time[i]+1 )
            if ( i <= length (esacc$time)){
              e=which(eyetracking_data$time==esacc$time[i] | eyetracking_data$time==esacc$time[i]-1 )
            }
            else {
              e=length(eyetracking_data$event)
            }	
          }else if (freq==1000){
            s=which(eyetracking_data$time==ssacc$time[i])
            if ( i <= length (esacc$time)){
              e=which(eyetracking_data$time==esacc$time[i])
            }
            else {
              e=length(eyetracking_data$event)
            }
          }
          
          eyetracking_data$event[s:e]="saccade"
          eyetracking_data$eventnumber[s:e]=i
          
        }
        
        for(i in 1:length(sblink$event)){
          if (freq==250){
            s=which(eyetracking_data$time==sblink$time[i] | eyetracking_data$time==sblink$time[i]+1 | eyetracking_data$time==sblink$time[i]+2 | eyetracking_data$time==sblink$time[i]+3)
            if ( i <= length (eblink$time)){
              e=which(eyetracking_data$time==eblink$time[i] | eyetracking_data$time==eblink$time[i]-1 | eyetracking_data$time==eblink$time[i]-2 | eyetracking_data$time==eblink$time[i]-3)
            }
            else {
              e=length(eyetracking_data$event)
            }
          }else if (freq==500){
            s=which(eyetracking_data$time==sblink$time[i] | eyetracking_data$time==sblink$time[i]+1)
            if ( i <= length (eblink$time)){
              e=which(eyetracking_data$time==eblink$time[i] | eyetracking_data$time==eblink$time[i]-1)
            }
            else {
              e=length(eyetracking_data$event)
            }
          }else if (freq==1000){
            s=which(eyetracking_data$time==sblink$time[i])
            if ( i <= length (eblink$time)){
              e=which(eyetracking_data$time==eblink$time[i])
            }
            else {
              e=length(eyetracking_data$event)
            }
          }
          
          eyetracking_data$event[s:e]="blink"
          eyetracking_data$eventnumber[s:e]=i
          
        }
        
        for(i in 1:length(sfix$event)){
          if (freq==250){
            s=which(eyetracking_data$time==sfix$time[i] | eyetracking_data$time==sfix$time[i]+1 | eyetracking_data$time==sfix$time[i]+2 | eyetracking_data$time==sfix$time[i]+3)
            if ( i <= length (efix$time)){
              e=which(eyetracking_data$time==efix$time[i] | eyetracking_data$time==efix$time[i]-1 | eyetracking_data$time==efix$time[i]-2 | eyetracking_data$time==efix$time[i]-3)
            }
            else {
              e=length(eyetracking_data$event)
            }
          }else if (freq==500){
            s=which(eyetracking_data$time==sfix$time[i] | eyetracking_data$time==sfix$time[i]+1)
            if ( i <= length (efix$time)){
              e=which(eyetracking_data$time==efix$time[i] | eyetracking_data$time==efix$time[i]-1)
            }
            else {
              e=length(eyetracking_data$event)
            }
          }else if (freq==1000){
            s=which(eyetracking_data$time==sfix$time[i])
            if ( i <= length (efix$time)){
              e=which(eyetracking_data$time==efix$time[i])
            }
            else {
              e=length(eyetracking_data$event)
            }
          }
          
          eyetracking_data$event[s:e]="fix"
          eyetracking_data$eventnumber[s:e]=i
          
        }
        
        # location information
        screen=c(1920,1080)
        center=screen/2
        box_size=300;
        fixcross=c(center[1]-box_size/2,center[2]-box_size/2,center[1]+box_size/2,center[2]+box_size/2) #put box of 300x300 around screen center for fixation cross
        location_stim=c(729.6, 367.2, 1190.4, 712.8)
        buffer_around_image=100 # in pix, buffer around image frame
        stim=c(location_stim[1:2]-buffer_around_image, location_stim[3:4]+buffer_around_image)
        
        
        eyetracking_data$looking=NA
        eyetracking_data$looking[eyetracking_data$x>=stim[1]&eyetracking_data$y>=stim[2]&eyetracking_data$x<=stim[3]&eyetracking_data$y<=stim[4]]="stim"
        #eyetracking_data$looking[eyetracking_data$x>=fixcross[1]&eyetracking_data$y>=fixcross[2]&eyetracking_data$x<=fixcross[3]&eyetracking_data$y<=fixcross[4]]="fixcross"
        
        #Account for blinks, get rid of 100ms before and after blink
        if (freq==250){eyetracking_data$add=4; f=25}else if (freq==500){eyetracking_data$add=2; f=50}else if (freq==1000){eyetracking_data$add=1; f=100}
        
        for (i in 1:length(sblink$event)){
          if (sblink$time[i]-100 > eyetracking_data$time[1]){
            s=which(eyetracking_data$time==sblink$time[i])-f
            e=which(eyetracking_data$time==sblink$time[i])-1
            eyetracking_data$event[s:e][eyetracking_data$event[s:e]=="fix"]=NA
          }
        }
        
        for (i in 1:length(eblink$event)){
          
          if (eblink$time[i]+4 < eyetracking_data$time[length(eyetracking_data$time)]){
            s=which(eyetracking_data$time==eblink$time[i])+1
          }
          else{
            s=length(eyetracking_data$time)
          }
          if (eblink$time[i]+100 < eyetracking_data$time[length(eyetracking_data$time)]){
            e=which(eyetracking_data$time==eblink$time[i])+f
          }
          else {
            e=length(eyetracking_data$time)
          }
          eyetracking_data$event[s:e][eyetracking_data$event[s:e]=="fix"]=NA
        }
        
        write.table(eyetracking_data,file=paste(path,subject,"_responseToSnacks_session", sessionNum,"_", b,"_run",run_num,"_eyetrack.txt",sep=""))
      }else{
      print("missing files")
      print(paste(path,subject,"_resopnseToSnacks_EyeTracking_session_",sessionNum,"_",b,"_run_", run_num,"*.asc",sep=""))
      print(paste(path,subject,"_responseToSnacks_session",sessionNum,"_",b,"*",time_stamp,".txt",sep=""))
      }
    }
  }
}

