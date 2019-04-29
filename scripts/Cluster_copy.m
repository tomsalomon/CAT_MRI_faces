clear;
close all;

% Define these variables
task_num=1;
ses_num=1;
model = 1;
cope_lev_1=24;
cope_lev_2=4;
cope_lev_3=1;
visualize_fsleyes=false; % True or False
zthresh='2.3'; % '2.3' or '3.1' or 'SVC_0*'
experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/';
output_dir = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/figures/';
% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

zthresh_str=strrep(num2str(zthresh),'.','_');
task_names={'task-responsetostim';'task-training';'task-probe';'task-localizer';};
task_name=task_names{task_num};
%group_analysis_path=[experiment_path,'models/model001/ses-',sprintf('%02.f',ses_num),'/group_analysis/'];
group_analysis_path=sprintf('%smodels/model00%i/ses-%02.f/group_analysis/', experiment_path,model,ses_num);

cope_main_path_options=dir([group_analysis_path,'group_',task_name,'*',zthresh_str,'*']);
if isempty(cope_main_path_options)
    error('Error: no results directory found. please make sure the paths are correctly defined')
elseif length(cope_main_path_options)==1
    analysis_dir_selection=1;
else
    analysis_dir_selection = listdlg('PromptString','Select an analysis directory:','SelectionMode','single','ListString',{cope_main_path_options.name},'ListSize',[500,400]);
end
origin_dir=[group_analysis_path,cope_main_path_options(analysis_dir_selection).name,sprintf('/cope%i.gfeat/cope%i.feat/',cope_lev_1,cope_lev_2)];
thresh_zstat=[origin_dir,sprintf('thresh_zstat%i.nii.gz',cope_lev_3)];
cluster_mask=[origin_dir,sprintf('cluster_mask_zstat%i.nii.gz',cope_lev_3)];
[~,tmp]=system(['fslstats ',cluster_mask,' -p 100']);
num_of_sig_cluster=str2double(tmp);

is_SVC = isnan(str2double(zthresh));
if is_SVC
str_end = ['_',zthresh];
else
    str_end = '';
end
    
output_filename = sprintf('task_%02i_ses_%02i_model_%02i_cope_%02i_%02i_%02i%s.nii.gz',...
task_num,ses_num,model,cope_lev_1,cope_lev_2,cope_lev_3,str_end);
if num_of_sig_cluster >= 1
copyfile(thresh_zstat, [output_dir,output_filename]);
elseif num_of_sig_cluster == 0
    warning('Selected cope yielded no significant clusters')
end
