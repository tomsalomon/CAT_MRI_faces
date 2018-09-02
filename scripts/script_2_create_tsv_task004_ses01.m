
% Make sure you run this script before analysing new subjects' data
% copy_behavioral_data; %

clear;
subjects_dirs=dir('./../sub-0*');
num_of_runs=2; % Number of runs in the response to faces task
% num_of_runs_per_scan=1; % only in the training there are 2 run
% stim_duration=1; % duration of stimuli in task (in secs)
task_num=4; % Number of task
ses_num=1; % Session number
ses_name=['ses-0',num2str(ses_num)];
behave_data_path = './../behavioral_data/';
parametricModulation=1;
blockDuration=16;

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


%% WRITE ONSET FILES DATA
for sub=1:length(subjects_dirs)
    
    sub_name=subjects_dirs(sub).name;
    sub_num=str2double(subjects_dirs(sub).name(end-2:end));
    sub_path=['./../',sub_name,'/',ses_name,'/'];
    
    for run=1:num_of_runs
        tsv_file_name=[sub_name,'_',ses_name,'_',task_name,'_run-0',num2str(run),'_events.tsv'];
        onsets_path=['./../',sub_name,'/',ses_name,'/model/model001/onsets/',task_name,'_run-0',num2str(run),'/'];
        if isempty(dir(onsets_path))
            mkdir(onsets_path);
        end
        
        % Display orders from the dynamic localizer task:
        % 0 - fixation; 1 - faces; 2 - objects
        switch run
            case 1
                displayOrder = [ 0 1 2 1 2 0 1 1 2 2 0 2 2 1 1 0 2 1 2 1 0 ];
            case 2
                displayOrder = [ 0 2 2 1 1 0 2 1 2 1 0 1 2 1 2 0 1 1 2 2 0 ];
        end


        %% 1. ONSETS
        
        % faces onset times
        cond_onsets_mat{1}(:,1)=(find(displayOrder==1)-1)*blockDuration;
        % objects onset times
        cond_onsets_mat{2}(:,1)=(find(displayOrder==2)-1)*blockDuration;
        
        %% 2. DURATION
        
        % add the mean RT as duration
        for cond_num=1:length(cond_onsets_mat)
            cond_onsets_mat{cond_num}(:,2)=blockDuration;
        end
        
        %% 3. PARAMETRERIC MODULATIONS
        
        % Modulation of 1
        for cond_num=1:length(cond_onsets_mat)
            cond_onsets_mat{cond_num}(:,3)=parametricModulation;
        end
        
        %% 4. save to tsv file
        % save to tsv file
        for cond_num=1:length(cond_onsets_mat)
            % save to txt file
            if cond_num<10
                dlmwrite([onsets_path,'cond00',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            else
                dlmwrite([onsets_path,'cond0',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            end
            cond_onsets_mat{cond_num}(:,4)=cond_num; %
        end
        
        fid = fopen([sub_path,tsv_file_name], 'w');
        fprintf(fid, 'onset\tduration\tmodulation\tregressor\n');
        fclose(fid);
        dlmwrite([sub_path,tsv_file_name],cell2mat(cond_onsets_mat'),'-append','delimiter','\t')
        
        clear('cond_onsets_mat');
        
    end % end of runs loop
end % end of subjects loop