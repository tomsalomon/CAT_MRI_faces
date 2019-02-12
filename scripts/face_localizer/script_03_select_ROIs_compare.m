% This code uses probability ROI masks based on anatomical and results from
% the functional localizer to create a functional ROI mask.

clear;
close all;

% create environment in order to be able to run FSL from Matlab
setenv('FSLDIR','/share/apps/fsl/'); %the FSL folder
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %the output type
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% Define the following variables
subjects = 1:50;
ROI_names = {'FFA_right','FFA_left','OFA_right','OFA_left','STS_right','STS_left'};

%Define the input files name:
input_table_path_1 = './selected_ROI_table_2018_08_15.txt';
input_table_path_2 = './selected_ROI_table_3.txt';

%Define the output file name:
output_table_path = './selected_ROI_table_final_2018_11_08.txt';

table1=readtable(input_table_path_1,'delimiter','\t','ReadVariableNames', true);
table2=readtable(input_table_path_2,'delimiter','\t','ReadVariableNames', true);
array1 = table2array(table1);
array2 = table2array(table2);
array1(isnan(array1))=999;
array2(isnan(array2))=999;

output_array = array2;
output_table = table2;

num_of_ROIs = length(ROI_names);
dlg_prompt = [ROI_names,ROI_names];
dlg_prompt{1} = sprintf('Cluster number:\n%s',dlg_prompt{1});
dlg_prompt{num_of_ROIs+1} = sprintf('Threshold map:\n%s',dlg_prompt{num_of_ROIs+1});
selected_ROI_table_headers = ['subject',ROI_names,strcat(ROI_names,'_threshold_map')];

disp(sum(array1(:,2:7)==array2(:,2:7))/length(array1));
inconclusive_subjects = subjects(~all(array1==array2,2));

output_array(output_array==999)=nan;
array1(array1==999)=nan;
array2(array2==999)=nan;

for sub_id = 1:numel(inconclusive_subjects)
    subject = inconclusive_subjects(sub_id);
    sub_name =  sprintf('sub-%03i',subject);
    
    sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
    merged_thresh_zstate_path = sprintf('%smerged_thresh_zstat.nii.gz',sub_path);
    zstat_path= [sub_path,'zstat.nii.gz'];
    
    txt=(sprintf('fsleyes /share/apps/fsl/data/standard/MNI152_T1_0.5mm.nii.gz -in linear -dr 40 220 %s -cm hsv %s -cm red-yellow -dr 3.1 9 --alpha 50 &',merged_thresh_zstate_path, zstat_path));
    clipboard('copy',txt);
    
    def_answers=strsplit(num2str(array2(subject,2:end)));
    def_answers2=strsplit(num2str(array1(subject,2:end)));
    for i = 1:length(def_answers)
        if ~strcmp(def_answers{i},def_answers2{i})
            def_answers{i} = strcat(def_answers{i},'/',def_answers2{i});
        end
    end
    dlg_title = sprintf('Select ROIs - subject %03i',subject);
    answer = inputdlgcol(dlg_prompt,dlg_title,1,def_answers,'on',2);
    answer_numeric=str2double(string(answer));
    answer_numeric(answer_numeric==999)=nan;
    output_array(subject,2:end)=answer_numeric(:)';
    output_table = array2table(output_array,'VariableNames',selected_ROI_table_headers);
    writetable(output_table,output_table_path,'delimiter','\t')
end

