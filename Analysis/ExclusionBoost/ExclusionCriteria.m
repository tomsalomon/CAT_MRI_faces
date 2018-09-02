function [Outliers, ValidSubects] = ExclusionCriteria(subjects,OutputPath,prefix,withBR)
% This function automates exclusion of participants in Cue Approach experiments

%  Note: This version works on one experiment at a time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In order to run the function, you must have the following functions in your folder: 
% 1. Training_analysis
% 2. Training_recode
% 3. FalseAlarm
% 4. Misses
% 5. ReachMinimslLadder
% 6. PlotLadders
% 7. binary_ranking_analysis - If you have it in your experiment 
%
% Note: "Training_recode" function were written specifically
% for stimuli in a specific numeric name format (originaly for faces). For other stimuli, you need
% to modify the Training_recode function first (or use a different
% function)
%
%
% Enjoy!
%% clear;
close all;

if nargin<4
    withBR=1; % did the experiment include binary ranking? (
end

if nargin<3
    prefix=''; % If you have muliple experiments outputs in the same folder --> write the experiment prefix to analize 
end

if nargin<2
    OutputPath='./../../Output/';
end

if nargin<1
    subjects=[101:149,151]; % Define here your subjects' codes.
end 
% exclude (only technical):
% 166 - no subject run under that code.



BR_Outliers=[];
%Z_thresh_4_outliears=2;

%% Binary Rankink Exclusion
if withBR==1
    BR_Outliers=binary_ranking_analysis(OutputPath,prefix);
    if  ~isempty(BR_Outliers)
        fprintf('\nSubjects %s were intransitive in their choices- thus should be excluded\n', BR_Outliers)

    else fprintf('\n No subjects should be excluded based on binary ranking\n')
    end
end
%% Training Exclusion
TrainingData= Training_analysis(subjects,OutputPath,prefix);
%TrainingData2=TrainingData(find(~cellfun(@isempty,TrainingData))); %  use
%only non-empty cells - if you apply onn multiple experiment with different number of subjects

FAData=cellfun(@FalseAlarm,TrainingData); % find the proportion of ladders below threshold
FAOutliers=find(FAData>0.05); % FA on more than 5%

MissesData=cellfun(@Misses,TrainingData); % find the proportion of missed trials
MissOutliers=find(MissesData>=0.1); % misses on more than 10%

MinLadderData=cellfun(@ReachMinimalLadder,TrainingData); % did reach Ladder < 200
MinLadderOutliers=find((MinLadderData));


%Outliers=find(zscore(Measurement)<=-Z_thresh_4_outliears); % for lowerbound outliers
%threshold_for_outliers=[mean(Measurement)+std(Measurement)*Z_thresh_4_outliears,mean(Measurement)-std(Measurement)*Z_thresh_4_outliears];

% 
TrainingOutliers=[FAOutliers; MissOutliers; MinLadderOutliers];
if ~isempty(TrainingOutliers)
    UniqueTrainingOutliers=subjects(unique(TrainingOutliers));
    fprintf('\nThe following subjects did not meet the criteria for engagement in training- thus should be excluded:\n\n')
end 
fprintf('\n %s did not meet FA criterion \n',num2str(subjects(FAOutliers)))
fprintf('\n %s did not meet Misses criterion\n',num2str(subjects(MissOutliers)))
fprintf('\n %s did not meet Minimal Ladder criterion \n',num2str(subjects(MinLadderOutliers)))


TrainingOutliersData=TrainingData(unique(TrainingOutliers));
cellfun(@PlotLadders,TrainingOutliersData); % Plot Ladders of Training Outliers 

try
    Outliers=union(UniqueTrainingOutliers ,BR_Outliers);
catch
    Outliers=[UniqueTrainingOutliers BR_Outliers];
end

ValidSubects = setdiff(subjects,Outliers);

save ValidSubects % Option - can be used later for other analyses (e.g. Probe)
end