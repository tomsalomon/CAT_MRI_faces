function [] = sort_binary_ranking(subjectID,order,outputPath)
% function [] = sort_BDM_Israel(subjectID,order,outputPath)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Rotem Botvinik November 2014 ====================
% ================= Modified by Tom Salomon, January 2015 =================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function sorts the stimuli according to the Binary ranking results

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   [subjectID,'_ItemRankingResults*']


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'stopGoList_allstim_order%d.txt', order
%   'stopGoList_trainingstim.txt'
%   'order_testcomp.txt'

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% subjectID = 'BM_9001';
% order = 1;
% outputPath = 'D:/Rotem/Matlab/Boost_Israel_New_Rotem/Output'; % On Rotem's PC 


%=========================================================================
%%  read in info from BDM1.txt
%=========================================================================

subj_rank_file=dir(fullfile(outputPath,[subjectID,'_ItemRankingResults*']));
fid=fopen(fullfile(outputPath,subj_rank_file.name));
BDM1_data=textscan(fid, '%s %s %f %f %f %f %f', 'HeaderLines', 1); %read in data as new matrix   
fclose(fid);

%=========================================================================
%%  Create matrix sorted by descending bid value
%========================================================================

[bids_sort,trialnum_sort_bybid]=sort(BDM1_data{4},'descend');
% [bids_sort,trialnum_sort_bybid]=sort(BDM1_data{3},'descend');

bid_sortedM(:,1)=trialnum_sort_bybid; %trialnums organized by descending bid amt
bid_sortedM(:,2)=bids_sort; %bids sorted large to small
bid_sortedM(:,3)=1:1:60; %stimrank

stimnames_sorted_by_bid=BDM1_data{2}(trialnum_sort_bybid);

%=========================================================================
%%   The ranking of the stimuli determine the stimtype
%=========================================================================

if order == 1
    bid_sortedM([           7 10 12 13 15 18                ], 4) = 11; % HV_beep
    bid_sortedM([ 3:6       8  9 11 14 16 17       19:22    ], 4) = 12; % HV_nobeep
    bid_sortedM([           44 45 47 50 52 53               ], 4) = 22; % LV_beep 
    bid_sortedM([ 39:42     43 46 48 49 51 54      55:58    ], 4) = 24; % LV_nobeep
    bid_sortedM([ 1:2            23:38             59:60    ], 4) = 0; % notTrained
else
    bid_sortedM([           8  9 11 14 16 17                ], 4) = 11; % HV_beep
    bid_sortedM([ 3:6       7 10 12 13 15 18       19:22    ], 4) = 12; % HV_nobeep
    bid_sortedM([           43 46 48 49 51 54               ], 4) = 22; % LV_beep 
    bid_sortedM([ 39:42     44 45 47 50 52 53      55:58    ], 4) = 24; % LV_nobeep
    bid_sortedM([ 1:2            23:38             59:60    ], 4) = 0; % notTrained
end % end if order == 1

itemsForTraining = bid_sortedM([3:22 39:58],:);
itemsNamesForTraining = stimnames_sorted_by_bid([3:22 39:58]);

%=========================================================================
%%  create stopGoList_allstim.txt
%   this file is used during probe
%=========================================================================

fid2 = fopen([outputPath '/' subjectID sprintf('_stopGoList_allstim_order%d.txt', order)], 'w');    

for i = 1:length(bid_sortedM)
    fprintf(fid2, '%s\t%d\t%d\t%d\t%d\t\n', stimnames_sorted_by_bid{i,1},bid_sortedM(i,4),bid_sortedM(i,3),bid_sortedM(i,2),bid_sortedM(i,1)); 
end
fprintf(fid2, '\n');
fclose(fid2);

fid3 = fopen([outputPath '/' subjectID '_stopGoList_trainingstim.txt'], 'w');    

for i = 1:length(itemsForTraining)
    fprintf(fid3, '%s\t%d\t%d\t%d\t%d\t\n', itemsNamesForTraining{i,1},itemsForTraining(i,4),itemsForTraining(i,3),itemsForTraining(i,2),itemsForTraining(i,1)); 
end
fprintf(fid3, '\n');
fclose(fid3);

end % end function

