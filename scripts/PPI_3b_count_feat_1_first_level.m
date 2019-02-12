
clear;

% Define these variables
sessions=1;
Subjects=1:50;
task_num=2;
models = 2:7; % 1 - GLM, 2:7 PPI


task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
num_of_runs_per_task=[2,8,4,2;1,0,4,2];
task_name=task_names{task_num};
design_template=['design_sub-001_',task_name,'_run-01.fsf'];
if all(models == 1) % GLM
    designs_template_dir='./../models/model001/ses-01/designs/';
elseif all(models == 2:7) % PPI
    designs_template_dir='./../models/model002/ses-01/designs/';
    if task_num ==2
        runs = [1,8]; % PPI - training - only use first and last scans
    end
end

progress = 0; %out of numel(sessions)*numel(models)*numel(Subjects)
h = waitbar(progress,'Creating designs');
completed_mat = [];
for session_num=sessions
    num_of_runs=num_of_runs_per_task(session_num,task_num);
    ses_name=['ses-',num2str(session_num,'%02i')];
    for model = models
        model_name = sprintf('model00%i',model);
        designs_dir=['./../models/',model_name,'/',ses_name,'/designs/'];
        
        for sub=Subjects
            sub_name=['sub-',num2str(sub,'%03i')];
            sub_path=['./../',sub_name,'/',ses_name,'/'];
            
            if isempty(dir([sub_path,'model/',model_name])) % skip subjects with no follow-up
                continue
            end
            for run= runs
                run_name=['run-',num2str(run,'%02i')];
                        progress = progress + 1/(numel(sessions)*numel(models)*numel(Subjects));
            waitbar(progress,h);
            is_feat_exist = ~isempty(dir([sub_path,'model/',model_name,'/*',run_name,'.feat']));
            completed_mat(end+1,:) = [session_num, model, sub, run, is_feat_exist];
            end % end of run
        end % end of subjects
    end % end of models
end % end of session
close(h)
completed_table = array2table(completed_mat,'variablenames',{'session','model','sub','run','valid_feat'})
