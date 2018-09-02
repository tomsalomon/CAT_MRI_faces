
clear;

% Define these variables
sessions=2;
Subjects=1:50;
task_num=3;

task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
num_of_runs_per_task=[2,8,4,2;1,0,4,2];
task_name=task_names{task_num};
design_template=['design_sub-001_',task_name,'_run-01.fsf'];
designs_template_dir=['./../models/model001/ses-01/designs/'];

for session_num=sessions
    num_of_runs=num_of_runs_per_task(session_num,task_num);
    ses_name=['ses-',num2str(session_num,'%02i')];
    designs_dir=['./../models/model001/',ses_name,'/designs/'];
    
    for sub=Subjects
        sub_name=['sub-',num2str(sub,'%03i')];
        sub_path=['./../',sub_name,'/',ses_name,'/'];
        
        if ~isempty(dir([sub_path,'sub*'])) % skip subjects with no follow-up
            for run=1:num_of_runs
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
                    fprintf(fout,'%s\n',s);
                end
                fin=fclose(fin);
                fout=fclose(fout);
            end % end of run
        end % end of skip subject with no followup
    end % end of subjects
end % end of session
