
%% This script will generate regrossors onset files for the probe task.
%% Make sure you run this script before analysing new subjects' MRI data.

%% Run copy_behavioral_data.m script to copy the behavioral data from the dropbox
%% folder into the MRI folder, renamed, before running this script

% Written by Tom Salomon
% June, 2016

close all;
clear;

subjects_dirs=dir('./../sub*'); % The location of all 'sub00x' dirs.
num_of_runs=4; % Number of MRI runs in the Probe
% num_of_blocks_per_scan=1; % only in the training there are 2 blocks in each scan
% stim_duration=1.5; % duration of stimuli in task (in secs) - need to calculate average for all subjects
task_num=3; % Number of task in the exoeriment

% Calculate mean RT in seconds, across all trials and all subjects
RT_all_subs=[];
subjects=[102,106,109:111,113,114,116,117,119:125,127:136,138:141,143:149];
RT_subject2=subjects-100;
for sub=RT_subject2
    sub_name=subjects_dirs(sub).name;
    sub_num=str2double(subjects_dirs(sub).name(end-2:end));
    probe_data=Probe_recode(sub_num,'./../behavioral_data/');
    RT_all_subs(end+1:end+length(probe_data(:,16)))=probe_data(:,16);
end
RT_all_subs(RT_all_subs<100|RT_all_subs>1500)=[]; % remove invalid missed trial
Mean_RT=mean(RT_all_subs)/1000; % mean RT in seconds

%% WRITE ONSET FILES DATA
for sub=1:length(subjects_dirs)
    order=2-rem(sub,2); % order 1 if subjID is odd, order 2 if even
    
    %   comparisons of interest
    switch order
        case 1
            HV_beep =   [7 10 12 13 15 18]; % HV_beep
            HV_nobeep = [8 9 11 14 16 17]; % HV_nobeep
            LV_beep =   [44 45 47 50 52 53]; % LV_beep
            LV_nobeep = [43 46 48 49 51 54]; % LV_nobeep
        case 2
            HV_beep =   [8 9 11 14 16 17]; % HV_beep
            HV_nobeep = [7 10 12 13 15 18]; % HV_nobeep
            LV_beep =   [43 46 48 49 51 54]; % LV_beep
            LV_nobeep = [44 45 47 50 52 53]; % LV_nobeep
    end % end switch order
    
    HV_sanity = [5 6]; % HV_nobeep - Sanity
    LV_sanity = [55 56]; % LV_nobeep - Sanity
    
    HV_neutral=[3 4 19 20 21 22]; % HV_nobeep - Not in probe
    LV_neutral=[39 40 41 42 57 58]; % LV_nobeep - Not in probe
    
    sub_name=subjects_dirs(sub).name;
    sub_num=str2double(subjects_dirs(sub).name(end-2:end));
    behave_data_files=dir(['./../behavioral_data/',sub_name,'_probe*']);
    [~,idx] = sort([behave_data_files.datenum]); % index of the task files sorted by date
    behave_data={behave_data_files(idx).name}; % file names sorted by date
    
    for run=1:num_of_runs
        
        new_path=['./../',sub_name,'/behav/'];
        new_name=['task00',num2str(task_num),'_run00',num2str(run),'/task00',num2str(task_num),'_run00',num2str(run),'.txt'];
        
        % place behavioral data in the correct location
        copyfile(['./../behavioral_data/',behave_data{run}],[new_path,new_name]);
        
        % Read the behavioral data
        fid1=fopen([new_path,new_name]);
        task_data=textscan(fid1, '%s%f%f%f%f%f%f%s%s%f%f%f%s%f%f%f%f%f%f','HeaderLines',1);
        fid1=fclose(fid1);
        probe_data=Probe_recode(sub_num,'./../behavioral_data/');
        
        probe_chose_left=probe_data(:,13);
        probe_Rank_left=probe_data(:,10);
        probe_Rank_right=probe_data(:,11);
        
        task_onsets=task_data{7};
        task_rank_stim_left=task_data{10};
        task_rank_stim_right=task_data{11};
        
        task_data{13}(strcmp(task_data{13},'b'))={1}; % response: 1 for left
        task_data{13}(strcmp(task_data{13},'y'))={0}; % response: 0 for right
        task_data{13}(strcmp(task_data{13},'x'))={999}; % response: 999 for no response
        task_data{13}=cell2mat(task_data{13});
        task_response=task_data{13};
        
        task_pair_type=task_data{14};
        task_outcome=task_data{15};
        task_RT=task_data{16}/1000; % in seconds
        task_bid_left=task_data{17};
        task_bid_right=task_data{18};
        
        Chosen_stimulus=zeros(size(task_rank_stim_right));
        Chosen_stimulus(task_response==0)=task_rank_stim_right(task_response==0); % subject chose right
        Chosen_stimulus(task_response==1)=task_rank_stim_left(task_response==1); % subject chose left
        Chosen_stimulus(task_response==999)=999; % missed trials
        
        probe_proportion_item_was_chosen=zeros(length(Chosen_stimulus),1);
        for i=1:length(Chosen_stimulus)
            probe_item_apperance=sum(probe_chose_left<=1&(probe_Rank_left==Chosen_stimulus(i)|probe_Rank_right==Chosen_stimulus(i)));
            probe_item_was_chosen=sum((probe_Rank_left==Chosen_stimulus(i)&probe_chose_left==1)|(probe_Rank_right==Chosen_stimulus(i)&probe_chose_left==0));
            probe_proportion_item_was_chosen(i)=probe_item_was_chosen/probe_item_apperance;
        end
        
        bid_difference=zeros(length(Chosen_stimulus),1); % WTP in BDM or Colley score in binary ranking: chosen-unchosen
        bid_difference(task_response==0)=task_bid_right(task_response==0)-task_bid_left(task_response==0); % subject chose right
        bid_difference(task_response==1)=task_bid_left(task_response==1)-task_bid_right(task_response==1); % subject chose left
        
        %% 1. ONSETS
        
        % High Value - Onsets
        cond_onsets_mat{1}(:,1)=task_onsets(task_pair_type==1&task_outcome==1); % HV_Go_was_chosen
        cond_onsets_mat{2}(:,1)=task_onsets(task_pair_type==1&task_outcome==1); % HV_Go_was_chosen - Modulated by choice
        cond_onsets_mat{3}(:,1)=task_onsets(task_pair_type==1&task_outcome==1); % HV_Go_was_chosen - Modulated by WTP difference
        
        cond_onsets_mat{4}(:,1)=task_onsets(task_pair_type==1&task_outcome==0); % HV_NoGo_was_chosen
        cond_onsets_mat{5}(:,1)=task_onsets(task_pair_type==1&task_outcome==0); % HV_NoGo_was_chosen - Modulated by choice
        cond_onsets_mat{6}(:,1)=task_onsets(task_pair_type==1&task_outcome==0); % HV_NoGo_was_chosen - Modulated by WTP difference
        
        cond_onsets_mat{7}(:,1)=task_onsets(task_pair_type==1&task_outcome~=999); % HV - Modulated by RT
        
        % Low Value - Onsets
        cond_onsets_mat{8}(:,1)=task_onsets(task_pair_type==2&task_outcome==1); % LV_Go_was_chosen
        cond_onsets_mat{9}(:,1)=task_onsets(task_pair_type==2&task_outcome==1); % LV_Go_was_chosen - Modulated by choice
        cond_onsets_mat{10}(:,1)=task_onsets(task_pair_type==2&task_outcome==1); % LV_Go_was_chosen - Modulated by WTP difference
        
        cond_onsets_mat{11}(:,1)=task_onsets(task_pair_type==2&task_outcome==0); % LV_NoGo_was_chosen
        cond_onsets_mat{12}(:,1)=task_onsets(task_pair_type==2&task_outcome==0); % LV_NoGo_was_chosen - Modulated by choice
        cond_onsets_mat{13}(:,1)=task_onsets(task_pair_type==2&task_outcome==0); % LV_NoGo_was_chosen - Modulated by WTP difference
        
        cond_onsets_mat{14}(:,1)=task_onsets(task_pair_type==2&task_outcome~=999); % LV - Modulated by RT
        
        % Sanity - Onsets
        cond_onsets_mat{15}(:,1)=task_onsets(task_pair_type==4&task_outcome==1); % Sanity_HV_was_chosen
        cond_onsets_mat{16}(:,1)=task_onsets(task_pair_type==4&task_outcome==1); % Sanity_HV_was_chosen - Modulated by choice
        cond_onsets_mat{17}(:,1)=task_onsets(task_pair_type==4&task_outcome==1); % Sanity_HV_was_chosen - Modulated by WTP difference
        
        cond_onsets_mat{18}(:,1)=task_onsets(task_pair_type==4&task_outcome==0); % Sanity_LV_was_chosen
        cond_onsets_mat{19}(:,1)=task_onsets(task_pair_type==4&task_outcome==0); % Sanity_LV_was_chosen - Modulated by choice
        cond_onsets_mat{20}(:,1)=task_onsets(task_pair_type==4&task_outcome==0); % Sanity_LV_was_chosen - Modulated by WTP difference
        
        cond_onsets_mat{21}(:,1)=task_onsets(task_pair_type==4&task_outcome~=999); % Sanity - Modulated by RT
        
        % missed trials - Onsets
        cond_onsets_mat{22}(:,1)=task_onsets(task_outcome==999); % missed trials
        %
        %         % motion paramters - Add later
        % cond_onsets_mat{23:28}(:,1)=; % 6 motion parameters..
        %  cond_onsets_mat{29}(:,1)=; % To be scrubbed - whatever exceeded FD and DVARS > 0.5...
        
        
        %% 2. DURATION
        
        % add the mean RT as duration
        for cond_num=1:21
            cond_onsets_mat{cond_num}(:,2)=Mean_RT;
        end
        
        %% 3. PARAMETRERIC MODULATIONS
        
        % Modulation of 1
        % High Value
        cond_onsets_mat{1}(:,3)=1; % HV_Go_was_chosen
        cond_onsets_mat{4}(:,3)=1; % HV_NoGo_was_chosen
        % Low Value
        cond_onsets_mat{8}(:,3)=1; % LV_Go_was_chosen
        cond_onsets_mat{11}(:,3)=1; % LV_NoGo_was_chosen
        % Sanity
        cond_onsets_mat{15}(:,3)=1; % Sanity_HV_was_chosen
        cond_onsets_mat{18}(:,3)=1; % Sanity_LV_was_chosen
        % missed trials
        cond_onsets_mat{22}(:,3)=1; % missed trials
        
        
        % Modulation by probe choice (demeaned)
        % High Value - Onsets
        cond_onsets_mat{2}(:,3)=probe_proportion_item_was_chosen(ismember(Chosen_stimulus,HV_beep))-mean(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,HV_beep))); % HV_Go_was_chosen - Modulated by choice
        cond_onsets_mat{5}(:,3)=probe_proportion_item_was_chosen(ismember(Chosen_stimulus,HV_nobeep))-mean(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,HV_nobeep))); % HV_NoGo_was_chosen - Modulated by choice
        % Low Value - Onsets
        cond_onsets_mat{9}(:,3)=probe_proportion_item_was_chosen(ismember(Chosen_stimulus,LV_beep))-mean(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,LV_beep))); % LV_Go_was_chosen - Modulated by choice
        cond_onsets_mat{12}(:,3)=probe_proportion_item_was_chosen(ismember(Chosen_stimulus,LV_nobeep))-mean(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,LV_nobeep))); % LV_NoGo_was_chosen - Modulated by choice
        % Sanity - Onsets
        cond_onsets_mat{16}(:,3)=probe_proportion_item_was_chosen(ismember(Chosen_stimulus,HV_sanity))-mean(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,HV_sanity))); % Sanity_HV_was_chosen - Modulated by choice
        cond_onsets_mat{19}(:,3)=probe_proportion_item_was_chosen(ismember(Chosen_stimulus,LV_sanity))-mean(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,LV_sanity))); % Sanity_LV_was_chosen - Modulated by choice
        
        % Modulation by WTP difference
        % High Value - Onsets
        cond_onsets_mat{3}(:,3)=bid_difference(ismember(Chosen_stimulus,HV_beep)); % HV_Go_was_chosen - Modulated by bid difference
        cond_onsets_mat{6}(:,3)=bid_difference(ismember(Chosen_stimulus,HV_nobeep)); % HV_NoGo_was_chosen - Modulated by bid difference
        % Low Value - Onsets
        cond_onsets_mat{10}(:,3)=bid_difference(ismember(Chosen_stimulus,LV_beep)); % LV_Go_was_chosen - Modulated by bid difference
        cond_onsets_mat{13}(:,3)=bid_difference(ismember(Chosen_stimulus,LV_nobeep)); % LV_NoGo_was_chosen - Modulated by bid difference
        % Sanity - Onsets
        cond_onsets_mat{17}(:,3)=bid_difference(ismember(Chosen_stimulus,HV_sanity)); % Sanity_HV_was_chosen - Modulated by bid difference
        cond_onsets_mat{20}(:,3)=bid_difference(ismember(Chosen_stimulus,LV_sanity)); % Sanity_LV_was_chosen - Modulated by bid difference
        
        
        % modulation by demeaned RT
        cond_onsets_mat{7}(:,3)=task_RT(task_pair_type==1&task_outcome~=999)-mean(task_RT(task_pair_type==1&task_outcome~=999)); % HV - Modulated by RT
        cond_onsets_mat{14}(:,3)=task_RT(task_pair_type==2&task_outcome~=999)-mean(task_RT(task_pair_type==2&task_outcome~=999)); % LV - Modulated by RT
        cond_onsets_mat{21}(:,3)=task_RT(task_pair_type==4&task_outcome~=999)-mean(task_RT(task_pair_type==4&task_outcome~=999)); % Sanity - Modulated by RT
        
        %% SAVE TXT FILES

        onsets_dir=['./../',sub_name,'/model/model001/onsets/task00',num2str(task_num),'_run00',num2str(run),'/'];
        for cond_num=1:length(cond_onsets_mat)
            if sum(cond_onsets_mat{cond_num}(:))==0
                cond_onsets_mat{cond_num}=[0,0,0];
            end
            
            % save to txt file
            if cond_num<10
                dlmwrite([onsets_dir,'cond00',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            else
                dlmwrite([onsets_dir,'cond0',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            end
        end
        clear('cond_onsets_mat');
    end % end of runs loop
end % end of subjects loop