
clear;
curr_dir=pwd;
cd './../models/model001/designs/';

for sub=30:44
    for task=4
        for run=1:2
            
            if sub<10
                sub_name=['sub00',num2str(sub)];
            else
                sub_name=['sub0',num2str(sub)];
            end

                task_name=['task00',num2str(task)];
                run_name=['run00',num2str(run)];

            
            % e.g. design_task002_first_level.fsf
            fin = fopen(['design_sub001_',task_name,'_run001_model001.fsf']);
            fout = fopen(['design_',sub_name,'_',task_name,'_',run_name,'_model001.fsf'],'w');
            
            while ~feof(fin)
                s = fgetl(fin);
                s = strrep(s, 'sub001', sub_name);
                s = strrep(s, 'run001', run_name);
                fprintf(fout,'%s\n',s);
                %             disp(s)
            end
            
            fin=fclose(fin);
            fout=fclose(fout);
            
        end
    end
end

cd(curr_dir);