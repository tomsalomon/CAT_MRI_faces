
% Make sure you run this script before analysing new subjects' data
% copy_behavioral_data; %

clear;
subjects_dirs=dir('./../sub-0*');
num_of_runs=8; % Number of runs in the training task
num_of_runs_per_scan=2; % only in the training there are 2 run
stim_duration=1; % duration of stimuli in task (in secs)
task_num=2; % Number of task
ses_num=1; % Session number
ses_name=['ses-0',num2str(ses_num)];
behave_data_path = './../behavioral_data/';

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
    behave_data_files=dir([behave_data_path,sub_name,'_training*']);
    [~,idx] = sortrows({behave_data_files.name}.','ascend'); % index of the task files sorted by name
    behave_data={behave_data_files(idx).name}; % file names sorted by name (by run num)
    
    for run=1:num_of_runs
        
        tsv_file_name=[sub_name,'_',ses_name,'_',task_name,'_run-0',num2str(run),'_events.tsv'];
        onsets_path=['./../',sub_name,'/',ses_name,'/model/model001/onsets/',task_name,'_run-0',num2str(run),'/'];
        if isempty(dir(onsets_path))
            mkdir(onsets_path);
        end
        
        % Read the behavioral data
        fid1=fopen([behave_data_path,behave_data{(num_of_runs_per_scan*run-1)}]);
        fid2=fopen([behave_data_path,behave_data{(num_of_runs_per_scan*run)}]);
        %         fid1=fopen([new_path,new_name]);
        
        probe_data=Probe_recode(sub_num,behave_data_path);
        probe_chose_left=probe_data(:,13);
        probe_Rank_left=probe_data(:,10);
        probe_Rank_right=probe_data(:,11);
        
        task_data1=textscan(fid1,'%s%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f','HeaderLines',1);
        task_data2=textscan(fid2,'%s%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f','HeaderLines',1);
        fid1=fclose(fid1);
        fid2=fclose(fid2);
        
        RankInd=[task_data1{14};task_data2{14}];
        task_onsets=[task_data1{5};task_data2{5}];
        bid_value=[task_data1{16};task_data2{16}];
        RT=[task_data1{7};task_data2{7}]/1000; % RT in seconds
        GSD_HV=[task_data1{11};task_data2{11}]/1000; % Go signal delay - HV
        GSD_LV=[task_data1{12};task_data2{12}]/1000; % Go signal delay - LV
        trial_type=[task_data1{6};task_data2{6}]; % 11 - HV Go; 12 - HV NoGo; 22 - LV Go; 24 - LV NoGo
        press_response = RT < 1.5;
        
        probe_prop_chosen=zeros(length(RankInd),1);
        for i=1:length(RankInd)
            probe_item_apperance=sum(probe_chose_left<=1&(probe_Rank_left==RankInd(i)|probe_Rank_right==RankInd(i)));
            probe_item_was_chosen=sum((probe_Rank_left==RankInd(i)&probe_chose_left==1)|(probe_Rank_right==RankInd(i)&probe_chose_left==0));
            probe_prop_chosen(i)=probe_item_was_chosen/probe_item_apperance;
        end
        
        %% 1. ONSETS
        % cond_onsets_mat's first row is the onset times
        cond_onsets_mat{1}=task_onsets(ismember(RankInd,HV_beep)&press_response); % HV_Go
        cond_onsets_mat{2}=task_onsets(ismember(RankInd,HV_beep)&press_response); % HV_Go - by choice
        cond_onsets_mat{3}=task_onsets(ismember(RankInd,HV_beep)&press_response); % HV_Go - by WTP
        cond_onsets_mat{4}=task_onsets(ismember(RankInd,HV_beep)&press_response); % HV_Go - by GSD
        
        cond_onsets_mat{5}=task_onsets(ismember(RankInd,LV_beep)&press_response); % LV_Go
        cond_onsets_mat{6}=task_onsets(ismember(RankInd,LV_beep)&press_response); % LV_Go - by choice
        cond_onsets_mat{7}=task_onsets(ismember(RankInd,LV_beep)&press_response); % LV_Go - by WTP
        cond_onsets_mat{8}=task_onsets(ismember(RankInd,LV_beep)&press_response); % LV_Go - by GSD
        
        cond_onsets_mat{9}=task_onsets(ismember(RankInd,HV_nobeep)&(~press_response)); % HV_NoGo
        cond_onsets_mat{10}=task_onsets(ismember(RankInd,HV_nobeep)&(~press_response)); % HV_NoGo - by choice
        cond_onsets_mat{11}=task_onsets(ismember(RankInd,HV_nobeep)&(~press_response)); % HV_NoGo - by WTP
        
        cond_onsets_mat{12}=task_onsets(ismember(RankInd,LV_nobeep)&(~press_response)); % LV_NoGo
        cond_onsets_mat{13}=task_onsets(ismember(RankInd,LV_nobeep)&(~press_response)); % LV_NoGo - by choice
        cond_onsets_mat{14}=task_onsets(ismember(RankInd,LV_nobeep)&(~press_response)); % LV_NoGo - by WTP
        
        cond_onsets_mat{15}=task_onsets(ismember(RankInd,[HV_beep,LV_beep])&(~press_response)); % Missed
        cond_onsets_mat{16}=task_onsets((~ismember(RankInd,[HV_beep,LV_beep]))&press_response); % False alarm
        cond_onsets_mat{17}=task_onsets(ismember(RankInd,[HV_sanity,LV_sanity,HV_neutral,LV_neutral])); % NoGo - Sanity and fillers
        cond_onsets_mat{18}=task_onsets(ismember(RankInd,[HV_beep,LV_beep])&press_response); % All Go - by RT

        %% 2. DURATION
        for cond_num=1:length(cond_onsets_mat)
            cond_onsets_mat{cond_num}(:,2)=stim_duration;
        end
        
        %% 3. PARAMETRIC MODULATIONS
        % add the fixed parametric modulation in the 3rd column
        for cond_num=[1,5,9,12,15:18]
            cond_onsets_mat{cond_num}(:,3)=1;
        end
      
        % add the probe choice (demeaned)  parametric modulation
        cond_onsets_mat{2}(:,3)=detrend(probe_prop_chosen(ismember(RankInd,HV_beep)&press_response),'constant'); % HV_Go - by choice
        cond_onsets_mat{6}(:,3)=detrend(probe_prop_chosen(ismember(RankInd,LV_beep)&press_response),'constant'); % LV_Go - by choice
        cond_onsets_mat{10}(:,3)=detrend(probe_prop_chosen(ismember(RankInd,HV_nobeep)&(~press_response)),'constant'); % HV_NoGo - by choice
        cond_onsets_mat{13}(:,3)=detrend(probe_prop_chosen(ismember(RankInd,LV_nobeep)&(~press_response)),'constant'); % LV_NoGo - by choice
        
        % modulation by Bid (demeaned)
        cond_onsets_mat{3}(:,3)=detrend(bid_value(ismember(RankInd,HV_beep)&press_response),'constant'); % HV_Go - by bid
        cond_onsets_mat{7}(:,3)=detrend(bid_value(ismember(RankInd,LV_beep)&press_response),'constant'); % LV_Go - by bid
        cond_onsets_mat{11}(:,3)=detrend(bid_value(ismember(RankInd,HV_nobeep)&(~press_response)),'constant'); % HV_NoGo - by bid
        cond_onsets_mat{14}(:,3)=detrend(bid_value(ismember(RankInd,LV_nobeep)&(~press_response)),'constant'); % LV_NoGo - by bid
        
         % modulation by GSD (Go Signal Delay; demeaned)
        cond_onsets_mat{4}(:,3)=detrend(GSD_HV(ismember(RankInd,HV_beep)&press_response),'constant'); % HV_Go - by GSD
        cond_onsets_mat{8}(:,3)=detrend(GSD_LV(ismember(RankInd,LV_beep)&press_response),'constant'); % LV_Go - by GSD

        % modulation by RT (demeaned)
        cond_onsets_mat{18}(:,3)=detrend(RT(ismember(RankInd,[HV_beep,LV_beep])&press_response),'constant'); % All Go - by RT

        %% 4. save to tsv file
        % save to tsv file
        for cond_num=1:length(cond_onsets_mat)
            if isempty(cond_onsets_mat{cond_num})
                cond_onsets_mat{cond_num}=[0,0,0];
            end
            dlmwrite([onsets_path,'cond',sprintf('%03.f',cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            cond_onsets_mat{cond_num}(:,4)=cond_num;
        end
        
        fid = fopen([onsets_path,tsv_file_name], 'w');
        fprintf(fid, 'onset\tduration\tmodulation\tregressor\n');
        fclose(fid);
        dlmwrite([onsets_path,tsv_file_name],cell2mat(cond_onsets_mat'),'-append','delimiter','\t')
        clear('cond_onsets_mat');
    end % end of runs loop
end % end of subjects loop