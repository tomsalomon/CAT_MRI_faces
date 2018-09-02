
clear;
curr_dir=pwd;
cd './../models/model001/designs/';
task_name='task001'; % change according to your task

MRI_path=['./../../../sub001/model/',task_name,'.gfeat'];
num_of_copes=length(dir([MRI_path,'/*cope*']));

for cope=2:num_of_copes % change according to the number of copes in task
    
    % e.g. design_group_task001.fsf
    fin = fopen(['design_group_',task_name,'_cope1.fsf']);
    cope_name=['cope',num2str(cope)];
    fout = fopen(['design_group_',task_name,'_',cope_name,'.fsf'],'w');
    
    while ~feof(fin)
        s = fgetl(fin);
        s = strrep(s, 'cope1', cope_name);
        fprintf(fout,'%s\n',s);
        %             disp(s)
    end
    
    fin=fclose(fin);
    fout=fclose(fout);
    
end

cd(curr_dir);