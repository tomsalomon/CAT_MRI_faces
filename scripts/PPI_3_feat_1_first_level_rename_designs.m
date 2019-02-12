
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
for session_num=sessions
    num_of_runs=num_of_runs_per_task(session_num,task_num);
    ses_name=['ses-',num2str(session_num,'%02i')];
    for model = models
        model_name = sprintf('model00%i',model);
        designs_dir=['./../models/',model_name,'/',ses_name,'/designs/'];
        
        for sub=Subjects
            progress = progress + 1/(numel(sessions)*numel(models)*numel(Subjects));
            waitbar(progress,h);
            sub_name=['sub-',num2str(sub,'%03i')];
            sub_path=['./../',sub_name,'/',ses_name,'/'];
            
            if isempty(dir([sub_path,'model/',model_name])) % skip subjects with no follow-up
                continue
            elseif isempty(dir([sub_path,'sub*'])) % skip subjects with no PPI model (no face ROI seed)
                continue
            end
            
            %             for run=1:num_of_runs
            for run= runs
                run_name=['run-',num2str(run,'%02i')];
                
                design_output=['design_',sub_name,'_',task_name,'_',run_name,'.fsf'];
                
                if strcmp(design_template,design_output)
                    continue
                end
                
                fin = fopen([designs_template_dir,design_template]);
                fout = fopen([designs_dir,design_output],'w');
                
                while ~feof(fin)
                    s = fgetl(fin);
                    s = strrep(s, 'sub-001', sub_name);
                    s = strrep(s, 'run-01', run_name);
                    s = strrep(s, 'ses-01', ses_name);
                    s = strrep(s, 'model002',model_name); % should only work in PPI models 2:7
                    fprintf(fout,'%s\n',s);
                end
                fin=fclose(fin);
                fout=fclose(fout);
            end % end of run
        end % end of subjects
    end % end of models
end % end of session
close(h)
