clear;

% Define these variables
task_num=1;
session_num=1;

designs_dir_path=['/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/models/model001/ses-0',num2str(session_num),'/designs/'];
task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
num_of_copes=[27,25,26,0];
task_name=task_names{task_num};

% timestamp
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

fid = fopen(['text_commands/text_6_group_',task_name,'_',timestamp,'.txt'] ,'a');

for cope=1:num_of_copes(task_num)
    cope_name=sprintf('cope%i',cope);
    design_name=['design_group_',task_name,'_',cope_name,'.fsf'];
    fprintf(fid,['feat ',designs_dir_path,design_name,'\n']);
end

% either way make sure the file is closed by the end of the script
fid=fclose(fid);