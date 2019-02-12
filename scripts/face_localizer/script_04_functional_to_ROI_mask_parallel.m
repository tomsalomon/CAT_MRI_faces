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
main_path = [pwd,'/../../'];
ROI_table = readtable('selected_ROI_table_2018_08_15.txt','delimiter','\t');
ROI_mat = table2array(ROI_table);
number_cores = 40;
if isempty(gcp('nocreate'))
parpool(number_cores)
end

% delete any old ROI masks created previously
system (sprintf('rm %s/Functional_ROI/*/ROI*.nii.gz',pwd))

num_ROIs = (size(ROI_table,2)-1)/2;
ROI_names = ROI_table.Properties.VariableNames(2:1+num_ROIs);

parfor_progress(length(subjects));
parfor subject = subjects
    sub_name =  sprintf('sub-%03i',subject);
    sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
    thresh_maps = dir([sub_path,'thresh_zstat_z*.nii.gz']);
    is_first_valid_cluster = true;
    for ROI_i = 1:num_ROIs
        cluster_i = ROI_mat(subject,1+ROI_i);
        % first map is map = 0 in the table;
        thresh_map_ind = 1 + ROI_mat(subject,1+num_ROIs +ROI_i);
        
        if isnan(cluster_i) % in case the ROI was not found - skip
            continue
        end
        cluster_mask_path= sprintf('%s%s',sub_path,thresh_maps(thresh_map_ind).name);
        cluster_mask_output = sprintf('%sROI_%02i_%s.nii.gz',sub_path,ROI_i,ROI_names{ROI_i});
        merged_cluster_mask_output = sprintf('%sclusters_mask.nii.gz',sub_path);
        
        % Binary map of each cluster
        system(sprintf('fslmaths %s -thr %i -uthr %i -bin %s',cluster_mask_path,cluster_i,cluster_i,cluster_mask_output));
        if is_first_valid_cluster
            system (sprintf('fslmaths %s -mul %i %s',cluster_mask_output,ROI_i,merged_cluster_mask_output));
            is_first_valid_cluster=false;
        else
            system (sprintf('fslmaths %s -mul %i -add %s %s',cluster_mask_output,ROI_i,merged_cluster_mask_output,merged_cluster_mask_output));
        end
    end
parfor_progress();
end
parfor_progress(0);
% close parallel pool
%delete(gcp('nocreate'));
system(sprintf('fslmerge -t %s/Face_ROI_all_subjects.nii.gz %s/Functional_ROI/sub-0*/clusters_mask.nii.gz',pwd,pwd));