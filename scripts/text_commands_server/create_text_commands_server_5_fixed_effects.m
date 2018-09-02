

clear;

% Define these variables
Subjects=[1:50];
task_num=3;
session_num=2;

designs_dir_path=['/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/models/model001/ses-0',num2str(session_num),'/designs/'];

task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
num_of_runs_per_task=[2,8,4,2;1,0,4,2];

task_name=task_names{task_num};
num_of_runs=num_of_runs_per_task(session_num,task_num);

% timestamp
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

fid = fopen(['text_commands/text_5_fixed_effects_',task_name,'_',timestamp,'.txt'] ,'a');

for sub=Subjects
    sub_name=['sub-',num2str(sub,'%03i')];
    design_name=['design_',sub_name,'_',task_name,'.fsf'];
    if ~isempty(dir([designs_dir_path,design_name])) % skip non-existing design (ses 02)
        fprintf(fid,['feat ',designs_dir_path,design_name,'\n']);
    end
end

% either way make sure the file is closed by the end of the script
fid=fclose(fid);