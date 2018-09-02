
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

function [probe_results,Probe_results_table]=Probe_analysis(subjects,outpath)

if nargin <2
    if nargin < 1
        subjects=[102,104:114,116:117,119:125,127:141,143:149]; % Define here your subjects' codes.
        %exclude:
        % 101 - Probe - missing LV NoGo
        % 103 - Technical audio issue during training. Did an additional training run without proper sound
        % 115 - clinical findings
        % 118 - moved a lot during scans, requested to stop 3 times at training
        % said he was not concentratred.
        % 126 - clinical findings
        % 142 - Training - minimal ladder
        % 151 - clinical findings
    end
    outpath='./../Output/'; % Output folder location
end



all_subjs_data{length(subjects)}={};
probe_results=zeros(length(subjects),10);
probe_results(:,1)=subjects;

for subjInd=1:length(subjects)
    
    data=Probe_recode(subjects(subjInd),outpath);
    % The Probe_recode function will join all present output file for each subject into a single matrix, these are the matrix columns:
    % 1-subjectID       2-scanner	 3-order        4-block         5-run       6-trial	 7-onsettime    8-ImageLeft	 9-ImageRight	10-bidIndexLeft
    % 11-bidIndexRight	12-IsleftGo	 13-Response    14-PairType     15-Outcome  16-RT	 17-bidLeft     18-bidRight
    
    all_subjs_data{subjInd}=data; %All subjects' data
    order=data(1,3);
    PairType=data(:,14);
    Outcome=data(:,15);

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


% % analyze the data for all subject
% means=zeros(1,length(probe_results(1,:))-6);
% stddevs=zeros(1,length(probe_results(1,:))-6);
% p_values=zeros(1,length(probe_results(1,:))-6);
% 
% Text{1}='\nHigh value GO vs NoGo';
% Text{2}='Low value GO vs NoGo';
% 
% Text{3}='\nGO Sanity check';
% Text{4}='NoGO Sanity check';
% 
% fprintf('\nProbe Results\n')
% fprintf('=============\n')
% for i=1:length(Text)
%     means(i)=mean(probe_results(:,i+6));
%     stddevs(i)=std(probe_results(:,i+6));
%     [~,p_values(i)]=ttest(probe_results(:,i+6),0.5);
%     fprintf([Text{i},': mean=%.2f, p=%.3f\n'],means(i),p_values(i));
% end
% stderr=stddevs.*(1/sqrt(length(subjects)));
% 
% Recognition_results=recognition_analysis(subjects);
% probe_for_recognition=probe_results(ismember(probe_results(:,1),Recognition_results(:,1)),:);
% r_values=zeros(1,length(probe_for_recognition(:,1)));
% 
% fprintf('\nCorrelation with correct IsGo? response\n')
% fprintf('=======================================\n')
% for i=1:length(Text)
%     [r_values(i)]=corr(probe_for_recognition(:,i+6),Recognition_results(:,3));
%     fprintf([Text{i},': r=%.2f\n'],r_values(i));
% end
% 
% % Demographics
% personalDetailsAllSubjects = joinPersonalDetails('*','./../',subjects);
% ages=double(cell2mat(personalDetailsAllSubjects(2:end,5)));
% gender=cell2mat(personalDetailsAllSubjects(2:end,4));
% fprintf ('\nMin-Max (mean) Age: %i-%i (Mean=%.2f, SD=%.2f)\n',min(ages),max(ages),mean(ages),std(ages));
% fprintf ('\nFemales: %i (%.1f%%)\n',sum(gender==1),100*sum(gender==1)/length(gender));

end %end of function