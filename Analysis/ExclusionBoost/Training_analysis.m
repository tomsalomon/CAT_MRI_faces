function TrainingData= Training_analysis(subjects,OutputPath,prefix)

% ~~ Script for analyzing training results, modified for face MRI experiment ~~
% ~~~~~~~~~~~~~~~ Tom Salomon, February 2016  ~~~~~~~~~~~~~~
%
% In order to run the script, you must locate and run the script from within
% "Analysis" folder. The script uses external function, called
% "Training_recode" which join all training txt files into one matrix. Please
% make sure that function is also present in the analysis folder.
%
% Note: this script and "Training_recode" function were written specifically
% for face stimuli in a specific numeric name format. For other stimuli, you may need
% to modify the Training_recode function first.
%
% Enjoy!

% clear;
% close all;

if nargin<3
    prefix='';
end

if nargin<2
    OutputPath='./../../Output/';
end

if nargin<1
    subjects=[301:312,314:326]; % Define here your subjects' codes.
end 
% exclude (only technical):
% 105 - code crashed

% cosider removal...
% 125 - reported she did not look at the images during trainig

TrainingData=cell(length(subjects),1);

RT_Correct_all_HL1_Allsubs=9999*ones(50,264);
RT_Correct_all_HL2_Allsubs=9999*ones(50,264);

for subjInd=1:length(subjects)
    
    % merge data for current subject's all training runs
    data=Training_recode(subjects(subjInd), OutputPath,prefix);
    TrainingData{subjInd}=data;
    % ladder in all trials
    Ladders1_with_duplicate=data(:,12);
    Ladders2_with_duplicate=data(:,13);
    
    % Where the ladders had changed
    Ladders1_Change_location=data(:,6)==11;
    Ladders2_Change_location=data(:,6)==22;
    
    %     % remove trials where ladder didn't change (NoGo trials)
    %     % add 750 for the very first trial
    %     Ladders1=[750;Ladders1_with_duplicate(Ladders1_Change_location)];
    %     Ladders2=[750;Ladders2_with_duplicate(Ladders2_Change_location)];
    Ladders1=[Ladders1_with_duplicate(Ladders1_Change_location)];
    Ladders2=[Ladders2_with_duplicate(Ladders2_Change_location)];
    
    
    % add data to a matrix with all other subjects
    Ladders1AllSubs(subjInd,:)=Ladders1';
    Ladders2AllSubs(subjInd,:)=Ladders2';
    
    
%     % plot Ladders for single subjects
%     figure (subjects(subjInd))
%     plot(Ladders1,'b-') % HV Ladder in blue
%     hold on
%     plot(Ladders2,'r-') % LV Ladder in red
%     ylim([-950,950])
%     
%     % calculate time subject needed to respond
%     time_2_response=data(:,7)-data(:,9);
%     % replace trials with no response with the mean time to respond
%     time_2_response(time_2_response>1000|time_2_response<-1000)=mean(time_2_response(time_2_response<=1000&time_2_response>=-1000));
%     % divide results to HV and LV
%     time_2_response1=time_2_response(Ladders1_Change_location);
%     time_2_response2=time_2_response(Ladders2_Change_location);
%     time_2_response1AllSubs(subjInd,:)=time_2_response1';
%     time_2_response2AllSubs(subjInd,:)=time_2_response2';
%     
%     % plot Ladders for single subjects
%     figure (subjects(subjInd))
%     plot(time_2_response1,'.-','color',[0.4,0.4,1]) % HV RT in blue
%     hold on
%     plot(time_2_response2,'.-','color',[1,0.4,0.4]) % LV RT in red
%     hold on
%     plot(1:length(time_2_response2AllSubs),zeros(1,length(time_2_response2AllSubs)),'--','color','black')
%     
end

%% plot Ladders for all subjects
% figure;
% 
% std_err1=std(Ladders1AllSubs)/sqrt(size(Ladders1AllSubs,1)); %standard error for HV
% std_err2=std(Ladders2AllSubs)/sqrt(size(Ladders2AllSubs,1)); %standard error for HV
% 
% boundedline(1:length(Ladders1),mean(Ladders1AllSubs,1),std_err1,'b','alpha')
% hold on
% boundedline(1:length(Ladders2),mean(Ladders2AllSubs,1),std_err2,'r','alpha')
% ylabel ('Go Signal Delay', 'fontsize',18)
% xlabel ('trials','fontsize',18)
% title('Boost, SSD=start at 750 msec','fontsize',10)
% 
% % plot time to respond for all subjects
% figure;
% 
% std_err1=std(time_2_response1AllSubs)/sqrt(size(time_2_response1AllSubs,1)); %standard error for HV
% std_err2=std(time_2_response2AllSubs)/sqrt(size(time_2_response2AllSubs,1)); %standard error for HV
% 
% boundedline(1:length(time_2_response1AllSubs),mean(time_2_response1AllSubs,1),std_err1,'b','alpha')
% hold on
% boundedline(1:length(time_2_response2AllSubs),mean(time_2_response2AllSubs,1),std_err2,'r','alpha')
% 
% ylabel ('Time to respond (ms)', 'fontsize',18)
% xlabel ('trials','fontsize',18)
% title('Boost, Time to respond','fontsize',10)
