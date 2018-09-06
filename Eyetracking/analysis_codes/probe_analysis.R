# Load libraries
library(stringr)
library(lme4)
library(lmerTest)
library(rstudioapi)

# Clear workspace
rm(list=ls())

# Define these variables:
sessionNum = 1 # 1- session 1 ; 2- follow-up
task_name = "Probe"
buffer_around_blink = 150 # time in ms to remove around blink 
screen=c(1920,1080) # size in pixels
buffer_around_image_factor = 1.2 # in relative size
fixcross_size = c(300,300) * buffer_around_image_factor; # size in pixels
stim_size = c(400, 500) * buffer_around_image_factor; # size in pixels
dist_from_center = 300 # distance of the stimuli's edge from the screen center

# location information
center=screen/2
center_stim_l = c(center[1] - (dist_from_center + stim_size[1]/2), center[2])
center_stim_r = c(center[1] + (dist_from_center + stim_size[1]/2), center[2])
location_stim_l=as.data.frame(matrix(unlist(c(center_stim_l - stim_size/2, center_stim_l + stim_size/2)),1,4,T))
location_stim_r=as.data.frame(matrix(unlist(c(center_stim_r - stim_size/2, center_stim_r + stim_size/2)),1,4,T))
location_fixcross=as.data.frame(matrix(unlist(c(center - fixcross_size/2, center + fixcross_size/2)),1,4,T))
colnames(location_stim_l) = c('min_x', 'min_y', 'max_x', 'max_y')
colnames(location_stim_r) = colnames(location_stim_l)
colnames(location_fixcross) = colnames(location_stim_l)

# CAT allocations
probe_items = c(7:18,43:54)
training_items = c(3:22,39:58)
go_items_order1 = c(7,10,12,13,15,18,44,45,47,50,52,53)
go_items_order2 = setdiff(probe_items,go_items_order1)

# define which subjects to analyze
if (sessionNum==1) {
  subjects=c(102,104:114,116:117,119:125,127:141,143:149)
  scans = c(1:4)
} else if (sessionNum==2) {
  subjects=c(102,104:105,108,110:112,114,117,120:123,127,129:131,133:136,138:140,144)
  scans = c(5:8)
}

ignore_bad_eye_tracking = c(107,110,122,124,130, 134,141, 145, 147,
                            120, 121, 137) # maybe
if (task_name == "Probe" & sessionNum == 1){
  ignore_bad_eye_tracking = c(ignore_bad_eye_tracking,101,104,128)
} else if (sessionNum == 2){
  ignore_bad_eye_tracking = c(ignore_bad_eye_tracking, 102, 105, 110, 121,122,123,135,143,
                              104) # maybe
}
subjects = subjects[-(subjects %in% ignore_bad_eye_tracking)]

# set paths
current_path=dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(current_path)
data_path = './../pre_processed_data/'
output_path = './analyzed_data/'

# Conversion from eyelink text file to data frame
eyetracker_text2df = function(x,filter='',delimiter = "\t") {
  if (filter == '') {
    dataframe_headers = c("time","x","y","pupil","V1","phase")
  } else if (filter == 'SSACC') {
    dataframe_headers = c("event","filler","empty","time")
    delimiter = "\ "
  } else if (filter == 'ESACC') {
    dataframe_headers = c("event","time","duration","startx","starty","endx","endy","amplitude","velocity","startx2","starty2","endx2","endy2","amplitude2","velocity2")
  } else if (filter == 'SFIX') {
    dataframe_headers = c("event","filler","e1","e2","time")
    delimiter = "\ "
  } else if (filter == 'EFIX') {
    dataframe_headers = c("event","time","duration","x","y","pupil","x2","y2","pupil2")
  } else if (filter == 'SBLINK') {
    dataframe_headers = c("event","filler","time")
    delimiter = "\ "
  } else if (filter == 'EBLINK') {
    dataframe_headers = c("event","time","duration")
  } 
  
  x_filtered = x[grep(filter,x)]
  # deal with non-blinker subject
  if (length(x_filtered) ==0) { 
    x_filtered = paste0(rep('\t ',length(dataframe_headers)))
  }
  df=structure(data.frame(matrix(unlist(strsplit(x_filtered,delimiter)),length(x_filtered),length(dataframe_headers),T)),  names=dataframe_headers)
  for (col_i in 1:length(dataframe_headers)) {
    is_numeric_col = mean(!is.na(suppressWarnings(as.numeric(as.character(df[,col_i])))))>0.05
    if (is_numeric_col) {
      df[,col_i]=suppressWarnings(as.numeric(as.character(df[,col_i])))
    }
  }
  return(df)
}

filelist = data.frame(file_ind=integer(), subjectID=integer(), scan=integer(), behavioral=character(), eyetracking=character(),stringsAsFactors=F)
ind=0
for (s in subjects){
  for (scan in scans){
    ind=ind+1
    filelist[ind,'file_ind'] = ind
    filelist$subjectID[ind] = s
    filelist$scan[ind] = scan
    filelist$behavioral[ind]  = paste0("",Sys.glob(paste0(data_path,"*",s,"*",task_name,"*_",scan,".txt")))
    filelist$eyetracking[ind] = paste0("",Sys.glob(paste0(data_path,"*",s,"*",task_name,"*_",scan,".asc")))  }
}
filelist$valid_eyetracker = !filelist$eyetracking==""
valid_files = filelist$file_ind[filelist$valid_eyetracker]
eyetrack_merged = c()
behave_merged = c()

# Loop over all files  ----------------------------------------
for (file_i in valid_files){
  progress =round(which(valid_files==file_i)/length(valid_files),4)*100
  print(paste0('Progress: ',progress,'%, File index: ',file_i))
  # read behavioral data
  behavioral=read.table(filelist$behavioral[file_i],header=T,na.strings=c(999,999000),sep="\t")
  order = behavioral$order[1];
  if (order == 1) {
    go_items = go_items_order1
  } else if (order == 2) {
    go_items = go_items_order2
  }
  behavioral$scan = filelist$scan[file_i]
   # read eyetracking data
  input = readLines(filelist$eyetracking[file_i])
  # get the frequency
  freq_line =unlist(strsplit(input[grep('RATE',input)[1]],"\t"))
  freq = as.numeric(freq_line[1+grep('RATE',freq_line)])
  
  ssacc = eyetracker_text2df(input,'SSACC')
  esacc = eyetracker_text2df(input,'ESACC')
  sfix = eyetracker_text2df(input,'SFIX')
  efix = eyetracker_text2df(input,'EFIX')
  sblink = eyetracker_text2df(input,'SBLINK')
  eblink = eyetracker_text2df(input,'EBLINK')
  
  # on rare occasions eyelink 2 SFIX at the beginning of the file
  if (nrow(sfix) - nrow(efix) == 1){
    if (sfix$time[2] < efix$time[1]){
      sfix=sfix[-2,]
    }
  }
  # skip files with missmatch between events start and end - these are usualy empty or corrupted files
  if (!(
    (nrow(ssacc) == nrow(esacc)) & (nrow(sfix) == nrow(efix)) & (nrow(sblink) == nrow(eblink)))){
    cat('\nWARNING! number of events do not match. skipping!\n',
        'you should look at this file:',filelist$eyetracking[file_i],'\n')
    next
  }
  
  #don't want header, figure out the first line that is not header
  for (line_i in 1:2000){
    if (!is.na(suppressWarnings(as.numeric(strsplit(input[line_i],"\t")[[1]][1])))){
      firstline=line_i
      break
    }
  }
  
  exclude=c(1:firstline,grep("MSG|SFIX|EFIX|SSACC|ESAC|SBLINK|EBLINK|SAMPLES|INPUT",input))
  eyetracking_data = eyetracker_text2df(input[-exclude])
  eyetracking_data$subjectID = behavioral$subjectID[1]
  eyetracking_data$session = sessionNum[1]
  eyetracking_data$scan = scan[1]
  eyetracking_data$trial = NA
  eyetracking_data$phase = NA
  eyetracking_data$event = 'fixation' #assume all non blink or saccade is fixation
  eyetracking_data$eventnumber = NA
  eyetracking_data$valid = (!is.na(eyetracking_data$x)) & (!is.na(eyetracking_data$y))
  
  # Analyze general eyetracking events: fixations, blinks and saccades =======================================
  eyetracking_events = data.frame(start = c(sfix$time,ssacc$time,sblink$time),end = c(efix$time,esacc$time,eblink$time))
  eyetracking_events$event = c(rep('fixation',nrow(sfix)), rep('saccade',nrow(ssacc)), rep('blink',nrow(sblink)))
  eyetracking_events$eventnumber = c(1:nrow(sfix),1:nrow(ssacc), 1:nrow(sblink))
  for (i in 1:length(eyetracking_events$event)){
    s1 = which.min(abs(eyetracking_data$time - eyetracking_events$start[i]))
    e1 = which.min(abs(eyetracking_data$time - eyetracking_events$end[i]))
    eyetracking_data$event[s1:e1]=eyetracking_events$event[i]
    eyetracking_data$eventnumber[s1:e1]=eyetracking_events$eventnumber[i]
    
    #Account for blinks, get rid of 100ms before and after blink
    if (eyetracking_events$event[i] == 'blink') {
      s2 = which.min(abs(eyetracking_data$time - (eyetracking_events$start[i] - buffer_around_blink)))
      e2 = which.min(abs(eyetracking_data$time - (eyetracking_events$end[i] + buffer_around_blink)))
      eyetracking_data$valid[s2:e2]=FALSE
    }
  }
  
  eyetracking_data$looking_at_stim_l = (eyetracking_data$x >= location_stim_l$min_x) & (eyetracking_data$y>=location_stim_l$min_y) & (eyetracking_data$x<=location_stim_l$max_x) & (eyetracking_data$y<=location_stim_l$max_y)
  eyetracking_data$looking_at_stim_l[(is.na(eyetracking_data$looking_at_stim_l) | !eyetracking_data$valid)] = FALSE
  eyetracking_data$looking_at_stim_r = (eyetracking_data$x >= location_stim_r$min_x) & (eyetracking_data$y>=location_stim_r$min_y) & (eyetracking_data$x<=location_stim_r$max_x) & (eyetracking_data$y<=location_stim_r$max_y)
  eyetracking_data$looking_at_stim_r[(is.na(eyetracking_data$looking_at_stim_r) | !eyetracking_data$valid)] = FALSE
  eyetracking_data$looking_at_fixation = (eyetracking_data$x >= location_fixcross$min_x) & (eyetracking_data$y>=location_fixcross$min_y) & (eyetracking_data$x<=location_fixcross$max_x) & (eyetracking_data$y<=location_fixcross$max_y)
  eyetracking_data$looking_at_fixation[(is.na(eyetracking_data$looking_at_fixation) | !eyetracking_data$valid)] = FALSE
  
  #eyetracking_data$looking_at_fixation = (eyetracking_data$x >= location_fixcross$min_x) & (eyetracking_data$y>=location_fixcross$min_y) & (eyetracking_data$x<=location_fixcross$max_x) & (eyetracking_data$y<=location_fixcross$max_y)
  
  # Analyze task behavioral data =======================================
  behavioral$freq = freq
  run_start_line=unlist(strsplit(input[grep("SYNCTIME",input)],"\t| "))
  run_start_time=as.numeric(run_start_line[2])
  behavioral$duration[is.na(behavioral$duration)] = 1.5
  trial_start_times=round(run_start_time+(behavioral$onset*1000))
  trial_end_times=round(trial_start_times+(behavioral$duration*1000))
  numtrials = length(behavioral$onset)
  # classify lines in eyetracking_data to choice/confirmation/fixation
  for (i in 1:numtrials){
    s1 = which.min(abs(eyetracking_data$time - trial_start_times[i]))
    e1 = which.min(abs(eyetracking_data$time - trial_end_times[i]))
    s2 = e1 + 1
    if (i<numtrials) {
      e2 = which.min(abs(eyetracking_data$time - trial_start_times[i+1])) - 1
    } else {
      e2 = length(eyetracking_data$time)
    }
    eyetracking_data$phase[s1:e1]="trial"
    eyetracking_data$phase[s2:e2]="ISI"
    eyetracking_data$trial[s1:e2]=i
    behavioral$gaze_stim_l [i] = mean(eyetracking_data$looking_at_stim_l[s1:e1])
    behavioral$gaze_stim_r [i] = mean(eyetracking_data$looking_at_stim_r[s1:e1])
    behavioral$fixation [i] = mean(eyetracking_data$looking_at_fixation[s1:e1])
    behavioral$gaze_ISI [i] = mean(eyetracking_data$looking_at_fixation[s2:e2])
  }

  eyetrack_tmp = eyetracking_data[eyetracking_data$phase %in% "trial",]
  eyetrack_merged = rbind(eyetrack_merged,eyetrack_tmp)
  behave_merged = rbind(behave_merged,behavioral)
  # output_filename = paste0(output_path,tail(unlist(strsplit( filelist$behavioral[file_i],'/')),n=1))
  # write.table(eyetracking_data,file=output_filename,sep = '\t',row.names = F)
}
behave_merged$scan = as.factor(behave_merged$scan)
behave_merged$PairType2 = as.factor(behave_merged$PairType)
print ('Completed! Saving all data into R data frame')
output_filename = paste0(output_path,'Eyetracking_Task_',task_name,'_Session',sessionNum,'.Rda')
save(eyetrack_merged,file=output_filename)
output_filename = paste0(output_path,'Summary_Task_',task_name,'_Session',sessionNum,'.Rda')
save(behave_merged,file=output_filename)
print (paste0('Done. You can find the data at: ',output_filename))

# Statistics
behave_merged$gaze_general = behave_merged$gaze_stim_l + behave_merged$gaze_stim_r
behave_merged$gaze_go = behave_merged$gaze_stim_r
behave_merged$gaze_nogo = behave_merged$gaze_stim_l
behave_merged$gaze_go[behave_merged$IsleftGo==1] = behave_merged$gaze_stim_l[behave_merged$IsleftGo==1]
behave_merged$gaze_nogo[behave_merged$IsleftGo==1] = behave_merged$gaze_stim_r[behave_merged$IsleftGo==1]
behave_merged$gaze_delta = behave_merged$gaze_go - behave_merged$gaze_nogo

descriptive_by_subject = data.frame(with(behave_merged,tapply(gaze_general , list(subjectID,scan),mean)))
subs2exclude = rownames(descriptive_by_subject[which (descriptive_by_subject$X1 < 0.5 | descriptive_by_subject$X2 <0.5),])
#subs2exclude=c()
data2analyze = behave_merged[!behave_merged$subjectID %in% subs2exclude,]
descriptive = data.frame(with(data2analyze,c(tapply(gaze_nogo , list(scan),mean),tapply(gaze_go , list(scan),mean))))
descriptive = data.frame(with(data2analyze,tapply(gaze_delta , list(scan),mean)))

colnames(descriptive) = 'mean Go - NoGo' 
rownames(descriptive) = paste0('Scan_',levels(data2analyze$scan))
print('mean proportion of the trial participants viewed the stimulus')
print(descriptive)
summary(lmer(gaze_delta ~ 1 + PairType2 +  (1|subjectID), data = subset(data2analyze, PairType <= 2)))
summary(lmer(gaze_delta ~ 1 +  (1|subjectID), data = subset(data2analyze, PairType <= 2)))

for (scan_i in scans) {
  cat("\n\nScan:",scan_i,'\n========\n')
  print(summary(lmer(gaze_delta ~ 1 + PairType2 + (1|subjectID), data = subset(data2analyze, PairType <= 2 & scan == scan_i) )))
}




#### FROM AKRAM (not everything works yet) ######
library(heplots)
labcex=1.5
axiscex=1.2
namecex=1.2
titlecex=1.8
pluscex=1.2
starcex=1.5
data2analyze$timechosen=NA
data2analyze$timeunchosen=NA
data2analyze$timechosen[data2analyze$Response=='b']=data2analyze$gaze_stim_l[data2analyze$Response=='b']
data2analyze$timechosen[data2analyze$Response=='y']=data2analyze$gaze_stim_r[data2analyze$Response=='y']
data2analyze$timeunchosen[data2analyze$Response=='b']=data2analyze$gaze_stim_r[data2analyze$Response=='b']
data2analyze$timeunchosen[data2analyze$Response=='y']=data2analyze$gaze_stim_l[data2analyze$Response=='y']

# data2analyze$numfixchosen[data2analyze$Response=='b']=data2analyze$numLeftFix[data2analyze$Response=='b']
# data2analyze$numfixchosen[data2analyze$Response=='y']=data2analyze$numRightFix[data2analyze$Response=='y']
# data2analyze$numfixunchosen[data2analyze$Response=='b']=data2analyze$numRightFix[data2analyze$Response=='b']
# data2analyze$numfixunchosen[data2analyze$Response=='y']=data2analyze$numLeftFix[data2analyze$Response=='y']

data2analyze$chose[data2analyze$IsleftGo==1&data2analyze$Response=='b']="Go"
data2analyze$chose[data2analyze$IsleftGo==0&data2analyze$Response=='y']="Go"
data2analyze$chose[data2analyze$IsleftGo==1&data2analyze$Response=='y']="NoGo"
data2analyze$chose[data2analyze$IsleftGo==0&data2analyze$Response=='b']="NoGo"
data2analyze$notchosen[data2analyze$IsleftGo==1&data2analyze$Response=='b']="NoGo"
data2analyze$notchosen[data2analyze$IsleftGo==0&data2analyze$Response=='y']="NoGo"
data2analyze$notchosen[data2analyze$IsleftGo==1&data2analyze$Response=='y']="Go"
data2analyze$notchosen[data2analyze$IsleftGo==0&data2analyze$Response=='b']="Go"


d=data.frame(subjectID=rep(levels(data2analyze$subjectID),2), PairType2=rep(levels(data2analyze$PairType2),2),time=c(data2analyze$timechosen,data2analyze$timeunchosen),ischosen=c(rep("chosen",length(data2analyze$timechosen)),rep("unchosen",length(data2analyze$timeunchosen))),whichchosen=c(data2analyze$chose,data2analyze$notchosen))

mod=lmer(time ~ ischosen * whichchosen + (1|subjectID), data=d, na.action=na.omit)

d2=subset(d,d$ischosen=="unchosen")
mod2=lmer(time ~ whichchosen + (1|subjectID), data=d2, na.action=na.omit) #simple effect within unchosen

m=cbind(tapply(data2analyze$timechosen,data2analyze$chose,mean),tapply(data2analyze$timeunchosen,data2analyze$notchosen,mean))
mchosen=aggregate(timechosen~subjectID+chose,data=data2analyze,mean)
munchosen=aggregate(timeunchosen~subjectID+notchosen,data=data2analyze,mean)
munchosen1=munchosen
mchosen1=mchosen
se=cbind(c(sd(mchosen1$timechosen[mchosen1$chose=="Go"]),sd(mchosen1$timechosen[mchosen1$chose=="NoGo"])),c(sd(munchosen1$timeunchosen[munchosen1$notchosen=="Go"]),sd(munchosen1$timeunchosen[munchosen1$notchosen=="NoGo"])))
colnames(m) = c('Chosen','Not Chosen')
par(mar=c(4,3,5,0.5), mgp=c(1.5,0.4,0),oma=c(.5,.5,.5,.5))
xvals=barplot(m,beside=T,space=c(.1,.1,.5,.1),ylim=range(0,.7),col=rep(c("forestgreen","firebrick3"),2),border=NA,ylab="Proportion total choice time eye on item",main=paste("Proportion of total choice time eye on item \n during Go vs. NoGo probe trials", sep=""), cex.lab=labcex-.1,cex.main=titlecex,axes=F)
Axis(side=2, labels=c("","0.1","0.2","0.3","0.4","0.5","0.6","1.0"),at=c(0,.1,.2,.3,.4,.5,.6,.7),cex.axis=axiscex)
axis.break(2,style="zigzag",breakpos=.65)
#errbar(xvals,m,m+se,m-se,pch="",add=T,lwd=2)
# lines(xvals[3:4],rep(.2,2),lwd=2)
# text(mean(xvals[3:4]),.23,'***',cex=starcex)
mtext("Eyes on", at=-1,side=1,line=.4,cex=1.2)
mtext("Go", at=xvals[1],side=1,line=.4,cex=1.2)
mtext("NoGo", at=xvals[2],side=1,line=.4,cex=1.2)
mtext("Go", at=xvals[3],side=1,line=.4,cex=1.2)
mtext("NoGo", at=xvals[4],side=1,line=.4,cex=1.2)
mtext("When", at=-1,side=1,line=1.75,cex=1.5)
mtext("Chosen", at=mean(xvals[1:2]),side=1,line=1.75,cex=1.5)
mtext("Not Chosen", at=mean(xvals[3:4]),side=1,line=1.75,cex=1.5)




