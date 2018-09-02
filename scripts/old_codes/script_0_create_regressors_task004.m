
% cd './models/model001/designs/';
clear;
subjects_dirs=dir('./../sub*');
num_of_runs=2; % Number of runs in the response to faces task
task_num=4; % task 4 - dynamic face localizer

blockDuration=16; % 16 seconds duration of each block
parametricModulation=1; % defualt

for sub=1:length(subjects_dirs)
    sub_name=subjects_dirs(sub).name;
    
    for run=1:2
        onsets_dir=['./../',sub_name,'/model/model001/onsets/task00',num2str(task_num),'_run00',num2str(run),'/'];
        
        % Display orders from the dynamic localizer task
        switch run
            case 1
                displayOrder = [ 0 1 2 1 2 0 1 1 2 2 0 2 2 1 1 0 2 1 2 1 0 ];
            case 2
                displayOrder = [ 0 2 2 1 1 0 2 1 2 1 0 1 2 1 2 0 1 1 2 2 0 ];
        end
        
        % faces onset times
        cond_onsets_mat{1}(:,1)=(find(displayOrder==1)-1)*blockDuration;
        % objects onset times
        cond_onsets_mat{2}(:,1)=(find(displayOrder==2)-1)*blockDuration;
        % fixation onset times
        cond_onsets_mat{3}(:,1)=(find(displayOrder==0)-1)*blockDuration;
        
        % add the 16 sec blockDuration in the 2nd column, 1 parametric modulation, and save to txt file
        onsets_dir=['./../',sub_name,'/model/model001/onsets/task00',num2str(task_num),'_run00',num2str(run),'/'];
        for cond_num=1:length(cond_onsets_mat)
            cond_onsets_mat{cond_num}(:,2)=blockDuration;
            cond_onsets_mat{cond_num}(:,3)=parametricModulation;
            % save to txt file
            if cond_num<10
                dlmwrite([onsets_dir,'cond00',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            else
                dlmwrite([onsets_dir,'cond00',num2str(cond_num),'.txt'],cond_onsets_mat{cond_num},'delimiter','\t')
            end
        end
    end
end
        
        % for sub=1:length(subjects)
        %     for run=1:2
        %
        %         fin = fopen('design_first_level_task004.fsf');
        %
        %         if sub<10
        %             sub_name=['sub00',num2str(sub)];
        %         else
        %             sub_name=['sub0',num2str(sub)];
        %         end
        %
        %         if run<10
        %             run_name=['run00',num2str(run)];
        %         else
        %             run_name=['run0',num2str(run)];
        %         end
        %
        %
        %         fout = fopen(['design_first_level_',sub_name,'_task004_',run_name,'_model001.fsf'],'w');
        %
        %         while ~feof(fin)
        %             s = fgetl(fin);
        %             s = strrep(s, 'sub001', sub_name);
        %             s = strrep(s, 'run001', run_name);
        %             fprintf(fout,'%s\n',s);
        % %             disp(s)
        %         end
        %
        %         fin=fclose(fin);
        %         fout=fclose(fout);
        %
        %     end
        % end
        %
        % cd './../../..';