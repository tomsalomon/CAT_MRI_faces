
% Make sure you run this script before analysing new subjects' data
% copy_behavioral_data; %

clear;
subjects_dirs=dir('./../sub*');
num_of_runs=8; % Number of runs in the response to faces task
num_of_runs_per_scan=2;
stim_duration=1; % duration of stimuli in task (in secs)
task_num=2;

for sub=1:length(subjects_dirs)
    order=2-rem(sub,2); % order 1 if subjID is odd, order 2 if even
    sub_num=str2double(subjects_dirs(sub).name(end-2:end));
    probe_data=Probe_recode(sub_num,'./../behavioral_data/');
    probe_chose_left=probe_data(:,13);
    probe_Rank_left=probe_data(:,10);
    probe_Rank_right=probe_data(:,11);
    
    
    
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
    behave_data_files=dir(['./../behavioral_data/',sub_name,'_training_run*']);
    [~,idx] = sort([behave_data_files.datenum]); % index of the task files sorted by date
    behave_data={behave_data_files(idx).name}; % file names sorted by date
    
    for run=1:num_of_runs
        
        new_path=['./../',sub_name,'/behav/'];
        new_name1=['task00',num2str(task_num),'_run00',num2str(run),'/task00',num2str(task_num),'_run00',num2str(num_of_runs_per_scan*run-1),'.txt'];
        new_name2=['task00',num2str(task_num),'_run00',num2str(run),'/task00',num2str(task_num),'_run00',num2str(num_of_runs_per_scan*run),'.txt'];
        
        % place behavioral data in the correct location
        copyfile(['./../behavioral_data/',behave_data{num_of_runs_per_scan*run-1}],[new_path,new_name1]);
        copyfile(['./../behavioral_data/',behave_data{num_of_runs_per_scan*run}],[new_path,new_name2]);
        
        % Read the behavioral data
        fid1=fopen([new_path,new_name1]);
        fid2=fopen([new_path,new_name2]);
        task_data1=textscan(fid1,'%s%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f','HeaderLines',1);
        task_data2=textscan(fid2,'%s%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f','HeaderLines',1);
        fid1=fclose(fid1);
        fid2=fclose(fid2);

        RankInd=[task_data1{14};task_data2{14}];
        task_onsets=[task_data1{5};task_data2{5}];
        
        probe_proportion_item_was_chosen=zeros(length(RankInd),1);
        for i=1:length(RankInd)
            probe_item_apperance=sum(probe_chose_left<=1&(probe_Rank_left==RankInd(i)|probe_Rank_right==RankInd(i)));
            probe_item_was_chosen=sum((probe_Rank_left==RankInd(i)&probe_chose_left==1)|(probe_Rank_right==RankInd(i)&probe_chose_left==0));
            probe_proportion_item_was_chosen(i)=probe_item_was_chosen/probe_item_apperance;
        end
        
        %% 1. ONSETS
        % cond_onsets_mat's first row is the onset times
        cond_onsets_mat{1}=task_onsets(ismember(RankInd,HV_beep)); % HV_Go
        cond_onsets_mat{2}=task_onsets(ismember(RankInd,HV_nobeep)); %HV_NoGo
        cond_onsets_mat{3}=task_onsets(ismember(RankInd,LV_beep)); % LV_Go
        cond_onsets_mat{4}=task_onsets(ismember(RankInd,LV_nobeep)); % LV_NoGo
        cond_onsets_mat{5}=task_onsets(ismember(RankInd,HV_neutral)); % HV_Neutral - not in probe
        cond_onsets_mat{6}=task_onsets(ismember(RankInd,LV_neutral)); % LV_Neutral - not in probe
        cond_onsets_mat{7}=task_onsets(ismember(RankInd,HV_sanity)); % HV_sanity
        cond_onsets_mat{8}=task_onsets(ismember(RankInd,LV_sanity)); % LV_sanity
        
        
        % parametric modulation by choice
        cond_onsets_mat{9}=task_onsets(ismember(RankInd,HV_beep)); % HV_Go
        cond_onsets_mat{10}=task_onsets(ismember(RankInd,HV_nobeep)); %HV_NoGo
        cond_onsets_mat{11}=task_onsets(ismember(RankInd,LV_beep)); % LV_Go
        cond_onsets_mat{12}=task_onsets(ismember(RankInd,LV_nobeep)); % LV_NoGo
        
        % All stim with modulation by Bid
        cond_onsets_mat{13}=task_onsets;
        
        %% 2. DURATION
        for cond_num=1:length(cond_onsets_mat)
            cond_onsets_mat{cond_num}(:,2)=stim_duration;
        end
        
        %% 3. PARAMETRIC MODULATIONS
        % add the fixed parametric modulation in the 3rd column
        for cond_num=1:8
            cond_onsets_mat{cond_num}(:,3)=1;
        end
        
        % add the probe choice (demeaned)  parametric modulation
        cond_onsets_mat{9}(:,3)=probe_proportion_item_was_chosen(ismember(RankInd,HV_beep))-mean(probe_proportion_item_was_chosen(ismember(RankInd,HV_beep)));
        cond_onsets_mat{10}(:,3)=probe_proportion_item_was_chosen(ismember(RankInd,HV_nobeep))-mean(probe_proportion_item_was_chosen(ismember(RankInd,HV_nobeep)));
        cond_onsets_mat{11}(:,3)=probe_proportion_item_was_chosen(ismember(RankInd,LV_beep))-mean(probe_proportion_item_was_chosen(ismember(RankInd,LV_beep)));
        cond_onsets_mat{12}(:,3)=probe_proportion_item_was_chosen(ismember(RankInd,LV_nobeep))-mean(probe_proportion_item_was_chosen(ismember(RankInd,LV_nobeep)));
        
        % All stim with modulation by Bid
        cond_onsets_mat{13}(:,3)=RankInd-mean(RankInd);
        
        %% 4. save to txt file
        onsets_dir=['./../',sub_name,'/model/model001/onsets/task00',num2str(task_num),'_run00',num2str(run),'/'];
        for cond_num=1:length(cond_onsets_mat)
            
            % save to txt file
            if cond_num<10
                dlmwrite([onsets_dir,'cond00',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            else
                dlmwrite([onsets_dir,'cond0',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            end
        end
        
    end % end of runs loop
end % end of subjects loop