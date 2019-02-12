clear;

% Define these variables
task_num=1;
session_num=1;
models = 1; % 1 - GLM, 2:7 PPI

task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
num_of_copes=[27,25,26,0];

if models(1)>1 && task_num ==2
    num_of_copes(task_num) = 4;
end

task_name=task_names{task_num};

% timestamp
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

fid = fopen(['text_commands/text_6_group_',task_name,'_',timestamp,'.txt'] ,'a');

for model = models
    model_name = sprintf('model%03i',model);
    designs_dir_path=['/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/models/',model_name,'/ses-0',num2str(session_num),'/designs/'];
    
    for cope=1:num_of_copes(task_num)
        cope_name=sprintf('cope%i',cope);
        design_name=['design_group_',task_name,'_',cope_name,'.fsf'];
        fprintf(fid,['feat ',designs_dir_path,design_name,'\n']);
    end
end
% either way make sure the file is closed by the end of the script
fid=fclose(fid);