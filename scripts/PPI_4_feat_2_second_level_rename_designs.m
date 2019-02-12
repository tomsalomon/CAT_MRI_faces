
clear;

% Define these variables
session_num=1;
Subjects=1:50;
task_num=2;
models = 2:7; % 1 - GLM, 2:7 PPI

task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
switch task_num
    case 2
        runs = [1,8];
end
task_name=task_names{task_num};
design_template=['design_sub-001_',task_name,'.fsf'];
ses_name=['ses-',num2str(session_num,'%02i')];
overwrite='Yes'; % used to
designs_template_dir = ['./../models/model002/',ses_name,'/designs/'];

progress = 0; %out of numel(models)*numel(Subjects)
h = waitbar(progress,'Creating designs');
for model = models
    model_name = sprintf('model00%i',model);
    designs_dir=['./../models/',model_name,'/',ses_name,'/designs/'];
    for sub=Subjects
        sub_name=['sub-',num2str(sub,'%03i')];
        sub_path=['./../',sub_name,'/',ses_name,'/'];
        
        if isempty(dir([sub_path,'model/',model_name])) % skip subjects with no follow-up
            continue
        end
        design_output=['design_',sub_name,'_',task_name,'.fsf'];
        
        % Avoid additional registration
        for run=runs
            run_name=['run-',num2str(run,'%02i')];
            feat_path=[sub_path,'/model/',model_name,'/',sub_name,'_',ses_name,'_',task_name,'_',run_name,'.feat/'];
            if isempty(dir(feat_path))
                continue
            end
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
        fin = fopen([designs_template_dir,design_template]);
        fout = fopen([designs_dir,design_output],'w');
        while ~feof(fin)
            s = fgetl(fin);
            s = strrep(s, 'sub-001', sub_name);
            s = strrep(s, 'model002', model_name);
            fprintf(fout,'%s\n',s);
        end
        fin=fclose(fin);
        fout=fclose(fout);
        progress = progress + 1/(numel(models)*numel(Subjects));
        waitbar(progress,h);
    end % end of subjects
end %end of models
close(h)

