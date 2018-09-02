% Count number of scrubbed TR volums and find oulier subjects
clc;
clear;
% Define according to your data
MRI_data_path='./../'; % the path where all the sub0XX file are located
subject_dirs=dir([MRI_data_path,'sub-*']);
task_num=3;
ses_num=2;
runs_per_task=[2,8,4,2]; % number of runs for each task
task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
task_name=task_names{task_num};
ses_name=sprintf('ses-%02d',ses_num);

regressors=dir([MRI_data_path,subject_dirs(1).name,'/ses-01/model/model001/onsets/',task_name,'_run-01/cond*.txt']);
regressors_names={'1 - HV Go','2 - HV Go - by choice','3 - HV Go - by WTP diff','4 - HV NoGo','5 - HV NoGo - by choice','6 - HV NoGo - by WTP diff','7 - HV - by RT','8 - LV Go','9 - LV Go - by choice','10 - LV Go - by WTP diff','11 - LV NoGo','12 - LV NoGo - by choice','13 - LV NoGo - by WTP diff','14 - LV - by RT','15 - Sanity HV','16 - Sanity HV - by choice','17 - Sanity HV - by WTP diff','18 - Sanity LV','19 - Sanity LV - by choice','20 - Sanity LV - by WTP diff','21 - Sanity - by RT','22 - Missed trials'};
interesting_regressors=[1:2,4:5,8:9,11:12];
% preallocate the trials count
invalid_trials=nan(length(subject_dirs)*runs_per_task(task_num),length(regressors));
new_line=0;
row_counter=0;
            fprintf('\nInvalid Regressors:')
            fprintf('\n===================\n')
for sub_num=1:length(subject_dirs)
    sub_name=sprintf('sub-%03d',sub_num);
    column_counter=0;
    for cond=1:length(regressors)
        column_counter=column_counter+1;
        for run_num=1:runs_per_task(task_num)
            run_name=sprintf('run-%02d',run_num);
            onsets_path=[MRI_data_path,sub_name,'/',ses_name,'/model/model001/onsets/',task_name,'_',run_name,'/'];
            conds=dir([onsets_path,'cond*.txt']);
            row_counter=row_counter+1;
            
            % Count valid trials
            invalid_regressor = 0;
            try
                cond_data=dlmread([onsets_path,conds(cond).name]);
                invalid_regressor=mean(abs(cond_data(:,3)))==0;
            catch
                if ~isempty(conds)
                invalid_regressor=1;
                end
            end
            invalid_trials(row_counter,column_counter)=invalid_regressor;
            if invalid_regressor&&ismember(cond,interesting_regressors)
                fprintf('%s_%s, %s\n',sub_name,run_name,regressors_names{cond})
                new_line=1;
            end
        end
        if new_line
            fprintf('\n')
            new_line=0;
        end
    end
end
subjects_num=repmat(1:length(subject_dirs),[runs_per_task(task_num),1]);
subjects_num=subjects_num(:);
runs_num=repmat(1:runs_per_task(task_num),[1,length(subject_dirs)])';

