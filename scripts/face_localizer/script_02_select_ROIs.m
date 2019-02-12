% This code uses probability ROI masks based on anatomical and results from
% the functional localizer to create a functional ROI mask.

clear;
close all;

% create environment in order to be able to run FSL from Matlab
setenv('FSLDIR','/share/apps/fsl/'); %the FSL folder
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %the output type
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

%Define the output file name:
selected_ROI_table_path = [pwd,'/selected_ROI_table_final_18_08_06.txt'];

% Define the following variables
subjects = 1:50;
session = 1;
model_name = 'model001';
task_name = 'task-localizer';
cope = 3;
ROI_names = {'FFA_right','FFA_left','OFA_right','OFA_left','STS_right','STS_left'};
ROI_anat_path = [pwd,'/Anatomical_ROI/'];
merged_anat_mask = [pwd,'/merged_anatomy_ROI_mask.nii.gz'];
min_prop_2b_included = 0.05; % min prop of cluster that need to be within the anatomy mask
p_values = 10.^(-4:-1:-10);
thersh_z_values = ceil(-10*norminv(p_values))/10;

ses_name = sprintf('ses-%02i',session);
cope_name = sprintf('cope%i',cope);


num_of_ROIs = length(ROI_names);
dlg_prompt = [ROI_names,ROI_names];
dlg_prompt{1} = sprintf('Cluster number:\n%s',dlg_prompt{1});
dlg_prompt{num_of_ROIs+1} = sprintf('Threshold map:\n%s',dlg_prompt{num_of_ROIs+1});
selected_ROI_table_headers = ['subject',ROI_names,strcat(ROI_names,'_threshold_map')];

try
    selected_ROI_table = readtable(selected_ROI_table_path,'delimiter','\t','ReadVariableNames', true);
    selected_ROI_mat = table2array(selected_ROI_table);
    subjects2fill = all(isnan(selected_ROI_mat(:,2:num_of_ROIs+1)),2); % find where no ROIs were selected
    subjects=subjects(subjects2fill);
catch
    selected_ROI_mat = nan(length(subjects),num_of_ROIs*2+1);
    selected_ROI_mat(:,1) = subjects';
end

def_answers=[repmat({''},[1,num_of_ROIs]),repmat({'0'},[1,num_of_ROIs])];

for sub_id = 1:numel(subjects)
    subject = subjects(sub_id);
    sub_name =  sprintf('sub-%03i',subject);
    sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
    merged_thresh_zstate_path = sprintf('%smerged_thresh_zstat.nii.gz',sub_path);
    zstat_path= [sub_path,'zstat.nii.gz'];
    
    txt=(sprintf('fsleyes /share/apps/fsl/data/standard/MNI152_T1_0.5mm.nii.gz -in linear -dr 40 220 %s -cm hsv %s -cm red-yellow -dr 3.1 9 --alpha 50 &',merged_thresh_zstate_path, zstat_path));
    clipboard('copy',txt);
    dlg_title = sprintf('Select ROIs - subject %03i',subject);
    answer = inputdlgcol(dlg_prompt,dlg_title,1,def_answers,'on',2);
    answer_numeric=str2double(string(answer));
    selected_ROI_mat(subject,2:end)=answer_numeric(:)';
    selected_ROI_table = array2table(selected_ROI_mat,'VariableNames',selected_ROI_table_headers);
    writetable(selected_ROI_table,selected_ROI_table_path,'delimiter','\t')
end

