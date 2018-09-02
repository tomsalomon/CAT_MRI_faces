
% Make sure you run this script before analysing new subjects' data
% copy_behavioral_data; %

clear;
subjects_dirs=dir('./../sub-0*');
num_of_runs=4; % Number of runs in the response to faces task
% num_of_runs_per_scan=1; % only in the training there are 2 run
% stim_duration=1; % duration of stimuli in task (in secs)
task_num=3; % Number of task
ses_num=2; % Session number
ses_name=['ses-0',num2str(ses_num)];
behave_data_path_ses1 = './../behavioral_data/';
if ses_num==1
    behave_data_path = behave_data_path_ses1;
else
    behave_data_path = [behave_data_path_ses1,'ses-02/'];
end

% Subjects to be included in the analysis (decide mean RT)
valid_subjects=[2,4:14,16:17,19:25,27:41,43:49]; % Define here your subjects' codes.
valid_subjects_have_data = zeros(size(valid_subjects));
for sub_ind = 1:length(valid_subjects)
        sub_name=subjects_dirs(valid_subjects(sub_ind)).name;
        sub_path=['./../',sub_name,'/',ses_name,'/'];
     % skip subjects with no followup
    if ~isempty(dir([sub_path,'*.nii.gz']))
        valid_subjects_have_data(sub_ind) = 1;
    end
end
% remove subjects with no followup data
valid_subjects(~valid_subjects_have_data)=[];

%exclude:
% 101 - Probe - missing LV NoGo 
% 103 - Technical audio issue during training. Did an additional training run without proper sound
% 115 - clinical findings
% 118 - moved a lot during scans, requested to stop 3 times at training
% said he was not concentratred.
% 126 - clinical findings
% 142 - Training - minimal ladder
% 151 - clinical findings

% exclude specipic scans (first row is the subject and scond row is the
% scans to exclude)
scans_exclusion=0;
if ses_num == 1
scans_exclusion =       [5,	8,  23; ...
                        1,	1,  4];
elseif ses_num == 2
    scans_exclusion =   [8,	11; ...
                        5,  7];
end

switch task_num
    case 1
        task_name='task-responsetostim';
    case 2
        task_name='task-training';
    case 3
        task_name='task-probe';
    case 4
        task_name='task-localizer';
end

% Calculate mean RT in seconds, across all trials and all subjects
RT_all_subs=[];
for sub=valid_subjects
    sub_name=subjects_dirs(sub).name;
    sub_num=str2double(subjects_dirs(sub).name(end-2:end));
    probe_data=Probe_recode(sub_num,behave_data_path);
   if ismember(sub,scans_exclusion(1,:))
    scan_num=(probe_data(:,4)-1)*2+probe_data(:,5);
    scan2exclude=scans_exclusion(2,sub==scans_exclusion(1,:));
    probe_data(scan_num==scan2exclude,:)=[]; % remove the excluded scan from the RT calculation
   end
    RT_all_subs(end+1:end+length(probe_data(:,16)))=probe_data(:,16);
end
RT_all_subs(RT_all_subs<100|RT_all_subs>1500)=[]; % remove invalid missed trial
Mean_RT=mean(RT_all_subs)/1000; % mean RT in seconds


%% WRITE ONSET FILES DATA
for sub=1:50
    
    sub_name=subjects_dirs(sub).name;
    sub_num=str2double(subjects_dirs(sub).name(end-2:end));
    sub_path=['./../',sub_name,'/',ses_name,'/'];
    
    % skip subjects with no followup
    if isempty(dir([sub_path,'*.nii.gz']))
        continue
    end
    
    order=2-rem(sub,2); % order 1 if subjID is odd, order 2 if even
    if sub==50
        order=1; % sub-50 was run as 51
    end
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
    behave_data_files=dir([behave_data_path,sub_name,'_probe*']);
    [~,idx] = sortrows({behave_data_files.name}.','ascend'); % index of the task files sorted by name
    behave_data={behave_data_files(idx).name}; % file names sorted by name (by run num)
    
    for run=1:num_of_runs
        tsv_file_name=[sub_name,'_',ses_name,'_',task_name,'_run-0',num2str(run),'_events.tsv'];
        onsets_path=['./../',sub_name,'/',ses_name,'/model/model001/onsets/',task_name,'_run-0',num2str(run),'/'];
        if isempty(dir(onsets_path))
            mkdir(onsets_path);
        end
        
        % Read the behavioral data
        fid1=fopen([behave_data_path,behave_data{run}]);
        task_data=textscan(fid1, '%s%f%f%f%f%f%f%s%s%f%f%f%s%f%f%f%f%f%f','HeaderLines',1);
        fid1=fclose(fid1);
        probe_data=Probe_recode(sub_num,behave_data_path);
        
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
        cond_onsets_mat{15}(:,1)=task_onsets(task_pair_type==4&task_outcome~=999); % Sanity
        
        % missed trials - Onsets
        cond_onsets_mat{16}(:,1)=task_onsets(task_outcome==999); % missed trials
        
        %% 2. DURATION
        
        % add the mean RT as duration
        for cond_num=1:16
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
        cond_onsets_mat{15}(:,3)=1; % Sanity
        % missed trials
        cond_onsets_mat{16}(:,3)=1; % missed trials
        
        
        % Modulation by probe choice (demeaned)
        % High Value - Onsets
        cond_onsets_mat{2}(:,3)=detrend(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,HV_beep)),'constant'); % HV_Go_was_chosen - Modulated by choice
        cond_onsets_mat{5}(:,3)=detrend(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,HV_nobeep)),'constant'); % HV_NoGo_was_chosen - Modulated by choice
        % Low Value - Onsets
        cond_onsets_mat{9}(:,3)=detrend(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,LV_beep)),'constant'); % LV_Go_was_chosen - Modulated by choice
        cond_onsets_mat{12}(:,3)=detrend(probe_proportion_item_was_chosen(ismember(Chosen_stimulus,LV_nobeep)),'constant'); % LV_NoGo_was_chosen - Modulated by choice
           
        % Modulation by WTP difference
        % High Value - Onsets
        cond_onsets_mat{3}(:,3)=bid_difference(ismember(Chosen_stimulus,HV_beep)); % HV_Go_was_chosen - Modulated by bid difference
        cond_onsets_mat{6}(:,3)=bid_difference(ismember(Chosen_stimulus,HV_nobeep)); % HV_NoGo_was_chosen - Modulated by bid difference
        % Low Value - Onsets
        cond_onsets_mat{10}(:,3)=bid_difference(ismember(Chosen_stimulus,LV_beep)); % LV_Go_was_chosen - Modulated by bid difference
        cond_onsets_mat{13}(:,3)=bid_difference(ismember(Chosen_stimulus,LV_nobeep)); % LV_NoGo_was_chosen - Modulated by bid difference
        
        % modulation by demeaned RT
        cond_onsets_mat{7}(:,3)=detrend(task_RT(task_pair_type==1&task_outcome~=999),'constant'); % HV - Modulated by RT
        cond_onsets_mat{14}(:,3)=detrend(task_RT(task_pair_type==2&task_outcome~=999),'constant'); % LV - Modulated by RT
        
        %% 4. save to tsv file
        % save to tsv file
        for cond_num=1:length(cond_onsets_mat)
            if isempty(cond_onsets_mat{cond_num})
                cond_onsets_mat{cond_num}=[0,0,0];
            end
            % save to txt file
            dlmwrite([onsets_path,'cond',sprintf('%03.f',cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            %cond_onsets_mat{cond_num}(:,4)=cond_num;
        end
        
        fid = fopen([onsets_path,tsv_file_name], 'w');
        fprintf(fid, 'onset\tduration\tmodulation\tregressor\n');
        fclose(fid);
        dlmwrite([onsets_path,tsv_file_name],cell2mat(cond_onsets_mat'),'-append','delimiter','\t')
        clear('cond_onsets_mat');
    end % end of runs loop
end % end of subjects loop