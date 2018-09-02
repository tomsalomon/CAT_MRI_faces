% Count number of scrubbed TR volums and find oulier subjects

clear;
% Define according to your data
MRI_data_path='./../'; % the path where all the sub0XX file are located
subject_dirs=dir([MRI_data_path,'sub-*']);
num_of_tasks=4; % number of BOLD tasks
ses_num=1;
runs_per_task=[2,8,4,2]; % number of runs for each task
thresh_for_outliers=2;
task_names={'task-responsetostim','task-training','task-probe','task-localizer'};

% preallocate the scrubbed volums count
scrubbed_vols=nan(length(subject_dirs),sum(runs_per_task));

ses_name=sprintf('ses-%02d',ses_num);
for sub_num=1:length(subject_dirs)
    sub_name=sprintf('sub-%03d',sub_num);
    column_counter=0;
    for task_num=1:num_of_tasks
        task_name=task_names{task_num};
        for run_num=1:runs_per_task(task_num)
            column_counter=column_counter+1;
            run_name=sprintf('run-%02d',run_num);
            path = [MRI_data_path,sub_name,'/',ses_name,'/'];
            find_confounds=dir([path,sub_name,'_',ses_name,'_',task_name,'_',run_name,'_bold_confounds.tsv']);
            if ~isempty(find_confounds) % if BOLD data did not undergo QA, leave NaN
                num_scrubbed_vols_in_run=0; % if BOLD data underwent QA, and no vols were scrubbed
                try
                    % Count scrubbed vols
                    confounds_data=tdfread([path,'/',find_confounds.name]);
                    num_scrubbed_vols_in_run=length(fieldnames(confounds_data))-9;
                catch
                end
                scrubbed_vols(sub_num,column_counter)=num_scrubbed_vols_in_run;
            end
        end
    end
end

% Display Outliers
sum_TR_removed=nansum(scrubbed_vols,2);
disp(['Threshold for ouliers: ',num2str(mean(sum_TR_removed)+2*std(sum_TR_removed))])
disp('===============================')
outliers=find(zscore(sum_TR_removed)>=thresh_for_outliers);
for i=1:length(outliers)
    disp([sprintf('sub%03d',outliers(i)),' had ',num2str(sum_TR_removed(outliers(i))),' TRs removed']);
end