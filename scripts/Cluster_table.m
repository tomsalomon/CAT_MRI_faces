clear;
close all;

% Define these variables
task_num=2;
ses_num=1;
model = 1;
cope_lev_1=22;
cope_lev_2=8;
cope_lev_3=2;
visualize_fsleyes=false; % True or False
zthresh='SVC_04'; % '2.3' or '3.1' or 'SVC_0*'
experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/';

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

if num_of_sig_cluster >= 1
    display_range='2.3 4.3';
    % visualize_cmd = ['fsleyes /share/apps/fsl/data/standard/MNI152_T1_0.5mm.nii.gz -in linear -dr 40 220 ',cluster_mask,' -cm hsv ',thresh_zstat,' -cm red-yellow -in none -dr ',display_range,' &'];
    visualize_cmd = ['fsleyes /share/apps/fsl/data/standard/MNI152_T1_0.5mm.nii.gz -dr 40 220 ',cluster_mask,' -cm hsv ',thresh_zstat,' -cm red-yellow -in none -dr ',display_range,' &'];
    
    if visualize_fsleyes
        system(visualize_cmd);
    end
    clipboard('copy',visualize_cmd);
    pause(0.1);
elseif num_of_sig_cluster == 0
    warning('Selected cope yielded no significant clusters')
end
