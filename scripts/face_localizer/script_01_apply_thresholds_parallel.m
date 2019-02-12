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
session = 1;
model_name = 'model001';
task_name = 'task-localizer';
cope = 3;
main_path = [pwd,'/../../'];
ROI_anat_path = [pwd,'/Anatomical_ROI/'];
merged_anat_mask = [pwd,'/merged_anatomy_ROI_mask.nii.gz'];
min_prop_2b_included = 0.05; % min prop of cluster that need to be within the anatomy mask
p_values = 10.^(-4:-1:-20);
thersh_z_values = ceil(-10*norminv(p_values))/10;
number_cores = 50;
parpool(number_cores)

ses_name = sprintf('ses-%02i',session);
cope_name = sprintf('cope%i',cope);

parfor_progress(numel(subjects));
parfor subject = subjects
    sub_name =  sprintf('sub-%03i',subject);
    sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
    
    feat_path = [main_path,sub_name,'/',ses_name,'/model/',model_name,'/',sub_name,'_',ses_name,'_',task_name,'.gfeat/',cope_name,'.feat/'];
    zstat_path_origin= [feat_path,'/stats/zstat1.nii.gz'];
    thresh_zstat_path_origin= [feat_path,'/stats/zstat1.nii.gz'];
    
    %     cluster_mask_path_origin= [feat_path,'/cluster_mask_zstat1.nii.gz'];
    
    volume_path_origin= fopen([feat_path,'thresh_zstat1.vol']);
    volume = fscanf(volume_path_origin,'%f');
    fclose(volume_path_origin);
    
    smoothness =   fopen([feat_path,'/stats/smoothness']);
    smoothness_l1 = strsplit(fgetl(smoothness));
    dlh = str2double(smoothness_l1(2));
    fclose(smoothness);
    
    zstat_path= [sub_path,'zstat.nii.gz'];
    thresh_zstat_path= [sub_path,'thresh_zstat.nii.gz'];
    
    if isempty(dir(sub_path))
        mkdir(sub_path)
        copyfile(zstat_path_origin,zstat_path);
        copyfile(thresh_zstat_path_origin,thresh_zstat_path);
    end
    
    for thresh_ind = 1:length(thersh_z_values)
        thresh_zstate_path = sprintf('%sthresh_zstat_z%i.nii.gz',sub_path,10*thersh_z_values(thresh_ind));
        [~,out] = system(sprintf('cluster -z %s -t %.1f -p 0.05 --dlh=%f --volume=%i -o %s',zstat_path,thersh_z_values(thresh_ind),dlh,volume,thresh_zstate_path));
        if length(out)<=97 % if the threshold yilds no significant clusters
            delete(thresh_zstate_path)
            continue
        end
    end
    merged_thresh_zstate_path = sprintf('%smerged_thresh_zstat.nii.gz',sub_path);
    system(sprintf('fslmerge -t %s %s*.nii.gz',merged_thresh_zstate_path,thresh_zstate_path(1:end-9)));
        parfor_progress;
end
parfor_progress(0);
% close parallel pool
delete(gcp('nocreate'));
