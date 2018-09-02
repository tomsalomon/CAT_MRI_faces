
clear;

% Define these variables
session_num=1;
Subjects=1:50;
task_num=1;

task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
num_of_runs_per_task=[2,8,4,2;1,0,4,2];
num_of_runs=num_of_runs_per_task(session_num,task_num);
task_name=task_names{task_num};
design_template=['design_sub-001_',task_name,'.fsf'];
ses_name=['ses-',num2str(session_num,'%02i')];
designs_dir=['./../models/model001/',ses_name,'/designs/'];
ses_name=['ses-',num2str(session_num,'%02i')];
overwrite='Yes'; % used to

for sub=Subjects
    sub_name=['sub-',num2str(sub,'%03i')];
    sub_path=['./../',sub_name,'/',ses_name,'/'];
    
    if isempty(dir([sub_path,'sub*'])) % skip subjects with no follow-up
        continue
    end
    design_output=['design_',sub_name,'_',task_name,'.fsf'];
    
    % Avoid additional registration
    for run=1:num_of_runs
        run_name=['run-',num2str(run,'%02i')];
        feat_path=[sub_path,'/model/model001/',sub_name,'_',ses_name,'_',task_name,'_',run_name,'.feat/'];
        
        % reg_standard in the first level feat is created after running higher
        % level analysis. send warning if it exist and ask parmisssion to overwrite.
        if ~isempty(dir([feat_path,'reg_standard'])) && (~strcmp(overwrite,'Yes to all'))
            overwrite=questdlg(['WARNING! It seems that ',design_output,' was previously run. Are you sure '...
                'you want to overwrite previous reg_standard and mat files?'],'OVERWRITE WARNING','No','Yes','Yes to all','No');
        end
        if strcmp(overwrite,'No')
            overwrite='Yes';
            continue
        end
        if ~isempty(dir([feat_path,'reg_standard']))
            system(['rm -r ',pwd,'/',feat_path,'reg_standard']);
        end
        system(['rm ',pwd,'/',feat_path,'reg/*.mat']);
        copyfile('/share/apps/fsl/etc/flirtsch/ident.mat',[feat_path,'reg/example_func2standard.mat'])
        copyfile([feat_path,'/mean_func.nii.gz'],[feat_path,'reg/standard.nii.gz'])
    end
    
    if strcmp(design_template,design_output)
        continue
    end
    fin = fopen([designs_dir,design_template]);
    fout = fopen([designs_dir,design_output],'w');
    while ~feof(fin)
        s = fgetl(fin);
        s = strrep(s, 'sub-001', sub_name);
        fprintf(fout,'%s\n',s);
    end
    fin=fclose(fin);
    fout=fclose(fout);
end % end of subjects
