
% Make sure you run this script before analysing new subjects' data
% copy_behavioral_data; %

clear;
subjects_dirs=dir('./../sub-0*');
num_of_runs=1; % Number of runs in the response to faces task
num_of_runs_per_scan=1; % only in the training there are 2 run
stim_duration=2; % duration of stimuli in task (in secs)
task_num=1; % Number of task
ses_num=2; % Session number
ses_name=['ses-0',num2str(ses_num)];
behave_data_path_ses1 = './../behavioral_data/';
if ses_num==1
    behave_data_path = behave_data_path_ses1;
else
    behave_data_path = [behave_data_path_ses1,'ses-02/'];
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


for sub=1:length(subjects_dirs)
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
    sub_path=['./../',sub_name,'/',ses_name,'/'];
    
    % skip subjects with no followup
    if isempty(dir([sub_path,'*.nii.gz']))
        continue
    end
    behave_data_files=dir([behave_data_path,sub_name,'_responseToStimuli*']);
    [~,idx] = sortrows({behave_data_files.name}.','descend'); % index of the task files sorted descending by name
    behave_data={behave_data_files(idx).name}; % file names sorted by name ('before' and then 'after')
    stopGoList_datafile=dir([behave_data_path_ses1,sub_name,'_stopGoList_allstim*']);
    stopGoList_data=readtable([behave_data_path_ses1,stopGoList_datafile.name],'Delimiter','\t');
    bids=stopGoList_data.Var4;
    
    for run=1:num_of_runs
        
        tsv_file_name=[sub_name,'_',ses_name,'_',task_name,'_run-0',num2str(run),'_events.tsv'];
        onsets_path=['./../',sub_name,'/',ses_name,'/model/model001/onsets/',task_name,'_run-0',num2str(run),'/'];
        if isempty(dir(onsets_path))
            mkdir(onsets_path);
        end
        % Read the behavioral data
        fid1=fopen([behave_data_path,behave_data{run}]);
        %         fid1=fopen([new_path,new_name]);
        task_data=textscan(fid1,'%s%f%f%s%f%s%f%f%f%f','HeaderLines',1);
        fclose(fid1);
        probe_data=Probe_recode(sub_num,behave_data_path);
        probe_chose_left=probe_data(:,13);
        probe_Rank_left=probe_data(:,10);
        probe_Rank_right=probe_data(:,11);
        probe_bid_value_left=probe_data(:,17);
        probe_bid_value_right=probe_data(:,18);
        
        RankInd=[task_data{7}];
        task_onsets=[task_data{9}];
        probe_proportion_item_was_chosen=zeros(length(RankInd),1);
        for i=1:length(RankInd)
            probe_item_apperance=sum(probe_chose_left<=1&(probe_Rank_left==RankInd(i)|probe_Rank_right==RankInd(i)));
            probe_item_was_chosen=sum((probe_Rank_left==RankInd(i)&probe_chose_left==1)|(probe_Rank_right==RankInd(i)&probe_chose_left==0));
            probe_proportion_item_was_chosen(i)=probe_item_was_chosen/probe_item_apperance;
        end
        
        % cond_onsets_mat's first row is the onset times
        % EV's with fixed parametric modulation
        cond_onsets_mat{1}(:,1)=task_onsets(ismember(RankInd,HV_beep)); % HV_Go
        cond_onsets_mat{2}(:,1)=task_onsets(ismember(RankInd,HV_nobeep)); %HV_NoGo
        cond_onsets_mat{3}(:,1)=task_onsets(ismember(RankInd,LV_beep)); % LV_Go
        cond_onsets_mat{4}(:,1)=task_onsets(ismember(RankInd,LV_nobeep)); % LV_NoGo
        cond_onsets_mat{5}(:,1)=task_onsets(ismember(RankInd,HV_neutral)); % HV_Neutral - not in probe
        cond_onsets_mat{6}(:,1)=task_onsets(ismember(RankInd,LV_neutral)); % LV_Neutral - not in probe
        cond_onsets_mat{7}(:,1)=task_onsets(ismember(RankInd,HV_sanity)); % HV_sanity
        cond_onsets_mat{8}(:,1)=task_onsets(ismember(RankInd,LV_sanity)); % LV_sanity
        
        
        % EV's with parametric modulation by choice
        cond_onsets_mat{9}(:,1)=task_onsets(ismember(RankInd,HV_beep)); % HV_Go
        cond_onsets_mat{10}(:,1)=task_onsets(ismember(RankInd,HV_nobeep)); %HV_NoGo
        cond_onsets_mat{11}(:,1)=task_onsets(ismember(RankInd,LV_beep)); % LV_Go
        cond_onsets_mat{12}(:,1)=task_onsets(ismember(RankInd,LV_nobeep)); % LV_NoGo
        
        % All stim with modulation by Bid
        cond_onsets_mat{13}(:,1)=task_onsets;
        cond_onsets_mat{13}(:,3)=RankInd-mean(RankInd);
        
        % add the fixed parametric modulation
        for cond_num=1:8
            cond_onsets_mat{cond_num}(:,3)=1;
        end
        % add the bid index (demeaned)  parametric modulation
        cond_onsets_mat{9}(:,3)=detrend(probe_proportion_item_was_chosen(ismember(RankInd,HV_beep)),'constant');
        cond_onsets_mat{10}(:,3)=detrend(probe_proportion_item_was_chosen(ismember(RankInd,HV_nobeep)),'constant');
        cond_onsets_mat{11}(:,3)=detrend(probe_proportion_item_was_chosen(ismember(RankInd,LV_beep)),'constant');
        cond_onsets_mat{12}(:,3)=detrend(probe_proportion_item_was_chosen(ismember(RankInd,LV_nobeep)),'constant');
        % All stim with modulation by Bid
        cond_onsets_mat{13}(:,3)=detrend(bids(RankInd),'constant');
        
        
        % add the 2 sec duration in the 2nd column and save to txt file
        for cond_num=1:length(cond_onsets_mat)
            cond_onsets_mat{cond_num}(:,2)=stim_duration;
            % save to txt file
            if cond_num<10
                dlmwrite([onsets_path,'cond00',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            else
                dlmwrite([onsets_path,'cond0',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            end
            %cond_onsets_mat{cond_num}(:,4)=cond_num; %
        end
        
        fid = fopen([sub_path,tsv_file_name], 'w');
        fprintf(fid, 'onset\tduration\tmodulation\tregressor\n');
        fclose(fid);
        dlmwrite([sub_path,tsv_file_name],cell2mat(cond_onsets_mat'),'-append','delimiter','\t')
        
    end % end of runs loop
end % end of subjects loop