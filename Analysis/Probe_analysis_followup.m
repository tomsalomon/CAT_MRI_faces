
% ~~~ Script for analyzing probe results, modified for face experiment ~~~
% ~~~~~~~~~~~~~~~ Tom Salomon, February 2015  ~~~~~~~~~~~~~~
%
% In order to run the script, you must locate and run the script from within
% "Analysis" folder. The script uses external function, called
% "Probe_recode" which join all probe output file into one matrix. Please
% make sure that function is also present in the analysis folder.
%
% Note: this script and "Probe_recode" function were written specifically
% for face stimuli in a specific numeric name format. For other stimuli, you need
% to modify the Probe_recode function first.
%
% Enjoy!

clear 

% subjects=[102,104:105,107:108,110:112,114,117,120:123,127,129:136,138:140,143:144]; % Define here your subjects' codes.
subjects=[102,104:105,108,110:112,114,117,120:123,127,129:131,133:136,138:140,144]; %37 subjects

%exclude:
% 103 was too tired during probe and training.

analysis_path=pwd; % Analysis folder location
outpath='./../Output/followup/'; % Output folder location
all_subjs_data{length(subjects)}={};
probe_results=zeros(length(subjects),10);
probe_results(:,1)=subjects;

for subjInd=1:length(subjects)
    
    data=Probe_recode_followup(subjects(subjInd));
    
   if isempty(data)
      disp(subjects(subjInd));
      continue
   end
    % The Probe_recode function will join all present output file for each subject into a single matrix, these are the matrix columns:
    % 1-subjectID       2-scanner	 3-order        4-block         5-run       6-trial	 7-onsettime    8-ImageLeft	 9-ImageRight	10-bidIndexLeft
    % 11-bidIndexRight	12-IsleftGo	 13-Response    14-PairType     15-Outcome  16-RT	 17-bidLeft     18-bidRight
    
    all_subjs_data{subjInd}=data; %All subjects' data
    order=data(1,3);
    if order==1 %define which stimuli were Go items: [High    Low]
        GoStim=[7 10 12 13 15 18   44 45 47 50 52 53];
    elseif order==2
        GoStim=[8  9 11 14 16 17   43 46 48 49 51 54];
    end
    
    PairType=data(:,14);
    Outcome=data(:,15);
    Rank_left=data(:,10);
    Rank_right=data(:,11);
    
    highest=ismember(Rank_left,7:12)&ismember(Rank_right,7:12);
    high_middle=ismember(Rank_left,13:18)&ismember(Rank_right,13:18);
    low_middle=ismember(Rank_left,43:48)&ismember(Rank_right,43:48);
    lowest=ismember(Rank_left,49:54)&ismember(Rank_right,49:54);
    
    HHGo_vs_HMNoGo=(ismember(Rank_left,7:12)&ismember(Rank_left,GoStim)&ismember(Rank_right,13:18))+(ismember(Rank_right,7:12)&ismember(Rank_right,GoStim)&ismember(Rank_left,13:18));
    HHNoGo_vs_HMGo=(ismember(Rank_left,7:12)&ismember(Rank_right,GoStim)&ismember(Rank_right,13:18))+(ismember(Rank_right,7:12)&ismember(Rank_left,GoStim)&ismember(Rank_left,13:18));
    LLGo_vs_LMNoGo=(ismember(Rank_left,49:54)&ismember(Rank_left,GoStim)&ismember(Rank_right,43:48))+(ismember(Rank_right,49:54)&ismember(Rank_right,GoStim)&ismember(Rank_left,43:48));
    LLNoGo_vs_LMGo=(ismember(Rank_left,49:54)&ismember(Rank_right,GoStim)&ismember(Rank_right,43:48))+(ismember(Rank_right,49:54)&ismember(Rank_left,GoStim)&ismember(Rank_left,43:48));
    
    % Organize data in a summary table
    probe_results(subjInd,2)=order;
    
    probe_results(subjInd,3)=sum(PairType==1&Outcome~=999); % High value GO vs NoGo - number of valid trials
    probe_results(subjInd,4)=sum(PairType==2&Outcome~=999); % Low value GO vs NoGo - number of valid trials
    probe_results(subjInd,5)=sum(PairType==4&Outcome~=999); % NoGo Sanity check - number of valid trials
    probe_results(subjInd,6)=sum(Outcome==999); % number of invalid trials
    
    probe_results(subjInd,7)=sum(PairType==1&Outcome==1)/sum(PairType==1&Outcome~=999); % High value GO vs NoGo - Percent chosen Go
    probe_results(subjInd,8)=sum(PairType==2&Outcome==1)/sum(PairType==2&Outcome~=999); % Low value GO vs NoGo - Percent chosen Go
    probe_results(subjInd,9)=sum(PairType==3&Outcome==1)/sum(PairType==3&Outcome~=999); % Go Sanity check - Percent chosen Sanely
    probe_results(subjInd,10)=sum(PairType==4&Outcome==1)/sum(PairType==4&Outcome~=999); % NoGo Sanity check - Percent chosen Sanely
    
end

Probe_results_table = cell(1+size(probe_results,1),size(probe_results,2));
Titles = {'Subject', 'Order', '#HighValue', '#LowValue', '#SanityNoGo', '#InvalidTrials', '%HighChoseGo', '%LowChoseGo', '%SanityGoChoseHigh', '%SanityNoGoChoseHigh'};
Probe_results_table(1,:) = Titles;
Probe_results_table(2:end,:) = num2cell(probe_results);


% analyze the data for all subject
means=zeros(1,length(probe_results(1,:))-6);
stddevs=zeros(1,length(probe_results(1,:))-6);
p_values=zeros(1,length(probe_results(1,:))-6);

Text{1}='\nHigh value GO vs NoGo';
Text{2}='Low value GO vs NoGo';

Text{3}='\nGO Sanity check';
Text{4}='NoGO Sanity check';

fprintf('\nProbe Results\n')
fprintf('=============\n')
for i=1:length(Text)
    means(i)=mean(probe_results(:,i+6));
    stddevs(i)=std(probe_results(:,i+6));
    [~,p_values(i)]=ttest(probe_results(:,i+6),0.5);
    fprintf([Text{i},': mean=%.2f, p=%.3f\n'],means(i),p_values(i));
end
stderr=stddevs.*(1/sqrt(length(subjects)));

Recognition_results=recognition_analysis(subjects,outpath);
probe_for_recognition=probe_results(ismember(probe_results(:,1),Recognition_results(:,1)),:);
r_values=zeros(1,length(probe_for_recognition(:,1)));

fprintf('\nCorrelation with correct IsGo? response\n')
fprintf('=======================================\n')
for i=1:length(Text)
    [r_values(i)]=corr(probe_for_recognition(:,i+6),Recognition_results(:,3));
    fprintf([Text{i},': r=%.2f\n'],r_values(i));
end
