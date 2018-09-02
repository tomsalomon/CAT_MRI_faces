
% Make sure you run this script before analysing new subjects' data
% copy_behavioral_data; %

clear;
subjects_dirs=dir('./sub*');
num_of_runs=2; % Number of runs in the response to faces task
num_of_runs_per_scan=1; % only in the training there are 2 run
stim_duration=2; % duration of stimuli in task (in secs)
task_num=1; % Number of task

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
    behave_data_files=dir(['./behavioral_data/',sub_name,'_responseToStimuli*']);
    [~,idx] = sort([behave_data_files.datenum]); % index of the task files sorted by date
    behave_data={behave_data_files(idx).name}; % file names sorted by date
    
    for run=1:num_of_runs
        
        new_path=[sub_name,'/behav/'];
        new_name=['task00',num2str(task_num),'_run00',num2str(run),'/task00',num2str(task_num),'_run00',num2str(run),'.txt'];

        % place behavioral data in the correct location
        copyfile(['./behavioral_data/',behave_data{run}],[new_path,new_name]);

        % Read the behavioral data
        fid1=fopen([new_path,new_name]);
        task_data=textscan(fid1,'%s%f%f%s%f%s%f%f%f%f','HeaderLines',1);

        RankInd=[task_data{7}];
        task_onsets=[task_data{9}];
        
        % cond_onsets_mat's first row is the onset times
        cond_onsets_mat{1}=task_onsets(ismember(RankInd,HV_beep)); % HV_Go
        cond_onsets_mat{2}=task_onsets(ismember(RankInd,HV_nobeep)); %HV_NoGo
        cond_onsets_mat{3}=task_onsets(ismember(RankInd,LV_beep)); % LV_Go
        cond_onsets_mat{4}=task_onsets(ismember(RankInd,LV_nobeep)); % LV_NoGo
        cond_onsets_mat{5}=task_onsets(ismember(RankInd,HV_neutral)); % HV_Neutral - not in probe
        cond_onsets_mat{6}=task_onsets(ismember(RankInd,LV_neutral)); % LV_Neutral - not in probe
        cond_onsets_mat{7}=task_onsets(ismember(RankInd,HV_sanity)); % HV_sanity
        cond_onsets_mat{8}=task_onsets(ismember(RankInd,LV_sanity)); % LV_sanity
        
        % for now, skip the parametric modulations EV's
        %{ 
        % with parametric modulation by choice
        cond_onsets_mat{9}=task_onsets_data{9}(ismember(RankInd,HV_beep)); % HV_Go
        cond_onsets_mat{10}=task_onsets_data{9}(ismember(RankInd,HV_nobeep)); %HV_NoGo
        cond_onsets_mat{11}=task_onsets_data{9}(ismember(RankInd,LV_beep)); % LV_Go
        cond_onsets_mat{12}=task_onsets_data{9}(ismember(RankInd,LV_nobeep)); % LV_NoGo
        % All stim with modulation by Bid
        cond_onsets_mat{12}=task_onsets_data{9};
        %}
        
        % add the fixed parametric modulation in the 3rd column
        for cond_num=1:length(cond_onsets_mat)
            cond_onsets_mat{cond_num}(:,3)=1;
        end
        
        % add the 2 sec duration in the 2nd column and save to txt file
        onsets_dir=['./',sub_name,'/model/model001/onsets/task00',num2str(task_num),'_run00',num2str(run),'/'];
        for cond_num=1:length(cond_onsets_mat)
            cond_onsets_mat{cond_num}(:,2)=stim_duration;
            
            % save to txt file
            if cond_num<10
                dlmwrite([onsets_dir,'cond00',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            else
                dlmwrite([onsets_dir,'cond0',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            end
        end   
    end % end of runs loop
end % end of subjects loop