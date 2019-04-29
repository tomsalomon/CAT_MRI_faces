# General Description ----

# MANUSCRIPT TITLE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Salomon, T., Botvinick-Nezer, R., Schonberg, T.

# Instructions: 
#   1. Download the data file "Probe_Data_Session_I.csv" or the data file "Probe_Data_Session_I.csv". Save it in the same directory as the current script. 
#      If the datafile is saved in a different directory, copy the local path of the data file to 'data_path' variable (line XX); e.g. "~/Downolads/"
#   2. Select the file to be analyzed by uncommenting the appropriate file name to 'my_datafile' variable (lines XX-XX)
#   3. If you do not have the 'lme4' and 'ggplot2' packages, install it (type to Consule 'install.packages("lme4")' or 'install.packages("ggplot2")').

# Data file description:
#   In the "probe_data.Rda" file you will find the raw data from the probe phase of ten experiments, and five follow-up sample from Experiments 1-2 and 7-9, 
#   described in Salomon et al. (2017). The code analyses the proportion of trials participants chose the Go items over No-GO items using a logistic regression
#   with subject's code as a random effect. The analysis indicate significant proportions in comparison to the null hypothesis of 50% chance level (log-odds = 0).
#   It also computes 95% CI, and plot the results in a forest plot.

# Data frame variables:
# --------------------
# Variables used in the  analysis:
#   "Outcome" - Binary variable indicating whether participant chose the Go item (1) or the NoGo item (0). This is the dependent variable in the logistic regression analysis.
#   "subjectID" - Participant's code, is used as a random effect in the logistic regression analysis.
#   "PairType" - Categorical veriable indicating the type of comparison:
#         1 - High value: Go vs. NoGo
#         2 - Low value: Go vs. NoGo
#         3   (not used)
#         4 - Sanity NoGo: High value NoGo vs. low value NoGo
#   "PairType2" - Same as PairType variable, only as a character class
#    Results are analyzed separately for each pair type, or with PairType as a fixed effect to estimate differences of Go choices in high versus low value pairs. 

# Other recorded variables:
#   "scanner" - Was the experiment conducted in an fMRI settings (True).
#   "order" - Used to counter-balance Go signal association during training
#   "block" - full presentation of all probe choices. Each experiment comprised of two blocks (1-2 in the first session, 3-4 in the second)
#   "run" - Each block was split into two runs, for compatibility with fMRI experimental settings.
#   "trial" - trial number          
#   "onsettime" - Stimuli onset time     
#   "ImageLeft" - The name of the stimulus left of the fixation cross      
#   "ImageRight"- The name of the stimulus right of the fixation cross     
#   "bidLeft" - The initial value of the stimulus left of the fixation cross (as estimate in a BDM or binary ranking task)
#   "bidRight" - The initial value of the stimulus right of the fixation cross (as estimate in a BDM or binary ranking task)
#   "bidIndexLeft" - The rank-order value of the stimulus left of the fixation cross (range: 1-60)   
#   "bidIndexRight" - The rank-order value of the stimulus right of the fixation cross (range: 1-60)
#   "IsleftGo" - Binary variable indicating if the left stimulus is Go (1) or No-Go (0). In sanity choices, high value items are indicated similarly to Go items.
#   "Response" - participant's choice: "u" - left item, "i" for right items, "x" if subject did not responde on time (RT>1500 ms). When subject responded by choosing 
#   the Go item (i.e. IsleftGo==1 & Response=="u", IsleftGo==0 & Response=="i"), the resulting Outcome will be (1).
#   "RT" - reaction time.

# Dependencies ----
library(rstudioapi) 
library(lme4)
library(ggplot2) 
library(reshape2)

# Set Workspace ----
rm(list=ls()) # Clear workspace
script_path = dirname(rstudioapi::getActiveDocumentContext()$path) # Get current path
# Set the datafile path. Change here if data file is not saved in the same directory as the script; e.g. "~/Downloads/"
data_path=paste0(script_path,"/")
output_path = data_path # where the plot will be saved
# Standard error function
se = function(x) { out=sqrt(var(x, na.rm = TRUE)/length(which(!is.na(x)))) }

# Load Data ----
file_name = "Probe_Data.csv"
probe_data=read.csv(paste0(data_path,file_name))

Results_df = c() # dataframe where results will be saved
n = c()
for (session_i in c(1,2)) {
  # Descriptive Statistics ----
  probe_data_tmp = subset(probe_data,session == session_i)
  probe_data_tmp$PairType3 = factor(probe_data_tmp$PairType2,c("Low_Value","High_Value","Sanity")) # reorder the factor levels
  n[session_i] = length(unique(probe_data_tmp$subjectID))
  header_text = paste("Session",session_i,"-",probe_data_tmp$label[1],": Descriptive statistics")
  writeLines(paste0("\n",header_text,"\n", paste0(rep("=",nchar(header_text)),collapse="")))
  
  writeLines(paste("n =",n[session_i])) # Number of Participants
  writeLines ("Proportion of trials Go items were chosen over NoGo:")
  
  means = tapply(probe_data_tmp$Outcome,probe_data_tmp$PairType2,mean,na.rm=T)
  means[3] = NA # ignore sanity trial but save last row for HV-LV differential effect statistics
  SEM=c(se(with(data=subset(probe_data_tmp,PairType==1), tapply(Outcome, subjectID, mean, na.rm=T))),
        se(with(data=subset(probe_data_tmp,PairType==2), tapply(Outcome, subjectID, mean, na.rm=T))), 
        NA)
  comparisons = c("High Value","Low Value","Difference")
  Results_df_tmp = data.frame(session_label = probe_data_tmp$label[1], comparison = comparisons, mean = means, SE = SEM,row.names = NULL)
  
  # Logistic Regression analysis Statistics ----
  HV = summary(glmer(Outcome ~ 1 + (1|subjectID),data=subset(probe_data_tmp,(PairType2=='High_Value')),na.action=na.omit,family=binomial)) 
  LV = summary(glmer(Outcome ~ 1 + (1|subjectID),data=subset(probe_data_tmp,(PairType2=='Low_Value')),na.action=na.omit,family=binomial))
  DIFF = summary(glmer(Outcome ~ 1 + PairType3 + (1|subjectID),data=subset(probe_data_tmp,PairType %in% c(1,2)),na.action=na.omit,family=binomial)) 
  
  # Organize into dataframe ----
  Results_df_tmp = cbind(Results_df_tmp, as.data.frame(rbind(HV$coefficients[1,],LV$coefficients[1,],DIFF$coefficients[2,])))
  colnames(Results_df_tmp)[colnames(Results_df_tmp)=="Pr(>|z|)"] = "p"
  
  # Significance indicator
  Results_df_tmp$p [!Results_df_tmp$comparison=="Difference"] = Results_df_tmp$p[!Results_df_tmp$comparison=="Difference"] * 0.5 # make p one-sided for the simple effects
  Results_df_tmp$asterisk="' '"
  #Results_df_tmp$asterisk[Results_df_tmp$p<0.1]="'+'"
  Results_df_tmp$asterisk[Results_df_tmp$p<0.1]="scriptstyle('+')"
  Results_df_tmp$asterisk[Results_df_tmp$p<0.05]="'*'"
  Results_df_tmp$asterisk[Results_df_tmp$p<0.01]="'**'"
  Results_df_tmp$asterisk[Results_df_tmp$p<0.001]="'***'"
  
  print(Results_df_tmp, right=FALSE, digits=3, row.names=FALSE) # display results
  n_text = n[session_i]
  sess_text = as.character(Results_df_tmp$session_label[1])
  Results_df_tmp$session_label2 = c(bquote(atop(.(sess_text),italic(n) == .(n[session_i]))))  # x labels workaround
  Results_df = rbind(Results_df,Results_df_tmp)
}

Results_df$CI_LogOdds_center=Results_df$Estimate
Results_df$CI_LogOdds_lower=Results_df$Estimate-Results_df$`Std. Error`*1.96
Results_df$CI_LogOdds_upper=Results_df$Estimate+Results_df$`Std. Error`*1.96
# 95% confidence interval (CI) and center estimate for the odds-ratio (no effect: odds-ratio=1)
Results_df$CI_OddsRatio_center=exp(Results_df$CI_LogOdds_center)
Results_df$CI_OddsRatio_lower=exp(Results_df$CI_LogOdds_lower)
Results_df$CI_OddsRatio_upper=exp(Results_df$CI_LogOdds_upper)

# Plot ----
plot_proportions =
  ggplot(data=subset(Results_df,!comparison=="Difference"), aes(x=session_label, y=mean, fill=comparison)) + 
  geom_bar(width=.7,colour="black",position=position_dodge(0.7), stat="identity") + # Bar plot
  theme_bw() + # white background
  theme(legend.position="top",legend.title=element_blank()) + # position legend
  theme(axis.title.x=element_blank(),axis.line = element_line(colour = "black"), panel.border = element_blank(), panel.background = element_blank()) + # axis and background formating
  theme(aspect.ratio=1,text = element_text(size=26)) + # espenct ration and font size
  geom_errorbar(position=position_dodge(.7), width=.7/4, aes(ymin=mean-SE, ymax=mean+SE))  + # add error bar of SEM
  scale_y_continuous("Proportion of trials Go items were chosen",limit=c(0,1),breaks=seq(0, 1, 0.1),expand = c(0,0)) + # define y axis properties
  scale_x_discrete(labels = unique(Results_df$session_label2))  + # x labels workaround
  scale_fill_manual(values=c("#585858","#D8D8D8")) + # color of bars
  geom_abline(intercept = (0.5),slope=0,linetype =2, size = 1,show.legend=TRUE,aes()) + # chace level 50% reference line
  geom_text(parse = TRUE,position=position_dodge(.7),aes(y=mean+SE+0.05,label=(asterisk)),size=8) # significance asterisk

# add high-value - low-value differential effect significance asterisk
for (session_i in 1:2) {
  differential_effect_ind = session_i*length(comparisons)
  if (Results_df$p[differential_effect_ind]<.1) {
    Lines_hight=max(Results_df$mean[differential_effect_ind-1]+Results_df$SE[differential_effect_ind-2])+0.13 # hight of significance line
    tmp_df=data.frame(x_val=c(session_i-.7/4,session_i-.7/4,session_i+.7/4,session_i +.7/4),y_val=c(Lines_hight-0.02,Lines_hight,Lines_hight,Lines_hight-0.02)) # define shafe of an open rectangle above the bar
    #tmp_df=rbind(tmp_df,tmp_df)
    tmp_df$comparison=Results_df$comparison[1]  # for compatability with the general plot
    plot_proportions = plot_proportions +
      geom_line(data = tmp_df, aes(x=x_val,y = y_val)) + # draw open rectangle
      annotate(parse = TRUE,"text", x = session_i, y = Lines_hight+0.05, label = (Results_df$asterisk[differential_effect_ind]),size=8) # differential effect significance asterisk
  }
}

dev.new(width=1, height=1)
plot_proportions
# Save plot as pdf
pdf(file=paste0(output_path,'Probe_results_plot.pdf'), width=7, height=7)
print(plot_proportions)
dev.off()

# Data organization for a boxplot ----

 data_agg=as.data.frame(aggregate(probe_data,by=list(probe_data$subjectID,probe_data$PairType,probe_data$session), mean, na.rm=TRUE))
 colnames(data_agg)[1] = "subjectID"
 Data_by_sub=melt(data_agg,id = c("subjectID", "session" ,"PairType") ,"Outcome")
 colnames(Data_by_sub)[ncol(Data_by_sub)] = "mean"
 Data_by_sub$comparison = as.factor(Data_by_sub$PairType)
 levels(Data_by_sub$comparison)= comparisons
 Data_by_sub$session_label = as.factor(Data_by_sub$session)
 levels(Data_by_sub$session_label) = levels(Results_df$session_label)
 Data_by_sub = Data_by_sub[Data_by_sub$PairType<=2,]

 Results_df$yloc = NA
 for (row_i in 1:nrow(Results_df)) {
   if  (Results_df$comparison[row_i]== "Difference"){
     data_i = 0.2 + Data_by_sub$mean[(Data_by_sub$session_label == Results_df$session_label[row_i])]
   } else {
     data_i = 0.05 + Data_by_sub$mean[(Data_by_sub$session_label == Results_df$session_label[row_i]) &
                                        (Data_by_sub$comparison == Results_df$comparison[row_i])]   }
   Results_df$yloc[row_i] = max(data_i)
 }

 Results_df2 = subset(Results_df,!comparison=="Difference")
 Results_df3 = subset(Results_df,comparison=="Difference")
 tmp_df2 = tmp_df
 # tmp_df2$x_val = tmp_df2$x_val-1
tmp_df2$y_val = c(.94, .96, .96, .94)

dev.new(width=1, height=1)
ggplot(data=subset(Data_by_sub,!comparison=="Difference"), aes(x=session_label, y=mean, fill=comparison)) +
  # geom_violin(trim=FALSE, position=position_dodge(.8))+
  geom_boxplot(notch=TRUE, position=position_dodge(.8), outlier.color = "gray30", outlier.size = 1) +
  theme_bw() + theme(legend.position="top",legend.title=element_blank()) + # position legend
  theme(axis.title.x=element_blank(),axis.line = element_line(colour = "black"), panel.border = element_blank(), panel.background = element_blank()) + # axis and background formating
  theme(aspect.ratio=1,text = element_text(size=20)) + # espenct ration and font size
  # geom_dotplot(binaxis='y', position=position_dodge(.8), stackdir='center', dotsize=.5, color = 1) +
  geom_hline(yintercept=0.5, linetype="dashed") +
  # theme(aspect.ratio=1, legend.position="none") +
  geom_text(data = Results_df2, aes(x=session_label, y = yloc, label = asterisk),parse = TRUE, position=position_dodge(.8), size = 10) +
  geom_text(data = Results_df3, aes(x=session_label, y = 0.98, label = asterisk),parse = TRUE,size = 10) +
  scale_fill_grey(start = 1, end = .4) +
  geom_line(data = tmp_df2, aes(x=x_val,y = y_val)) +
  scale_y_continuous("Proportion of trials Go items were chosen",limit=c(0,1),breaks=seq(0, 1, 0.1),expand = c(0,0))  # define y axis properties

  geom_text(data = SummaryTable, aes(y = yloc*1.1, label = non_significant, fontface=3),size = 3) +
  labs( x = x_lab, y = y_lab) +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank()) + # remove x and y labs
  scale_fill_grey(start = 0.9, end = .2) +

Results_df_tmp$asterisk[Results_df_tmp$p<0.1]= "scriptstyle('+')"

#####
