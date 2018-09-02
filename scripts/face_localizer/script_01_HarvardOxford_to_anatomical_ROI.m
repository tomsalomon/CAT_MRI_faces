% This code uses probability maps from the Harvard-Oxford atlas (fsl) to
% create ROI masks based on anatomical region
% To use the code, save the probability maps of any region you will use
% into the ProbabilityMaskPath. Use numerical coding (ROI_codes) to
% indicate which anatomical regions will be used for every ROI (e.g. for a
% general fusiform gyrus ROI use both 38 and 39 - Harard Oxford temporal
% fusiform gyri; save them in:
% 'Harvard_Oxford_probability_masks/39_TemporalOccipitalFusiformCortex.nii.gz'.

clear 
close all

% create environment in order to be able to run FSL from Matlab
setenv('FSLDIR','/share/apps/fsl/'); %the FSL folder
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %the output type
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% Define the following variables
ProbabilityMaskPath = [pwd,'/Harvard_Oxford_probability_masks/'];
ref_functional = [pwd,'/example_output_nifty.nii.gz']; % reference func image. will be used to match dimensions
OutputPath = [pwd,'/Anatomical_ROI/'];
ROI_names = {'FFA','OFA','STS'};
ROI_codes = {[15,38,39],40,[10,12]}; % each anatomical ROI's components to be merged

[~,ref_dim_tmp]=system(['fslsize ',ref_functional]);
ref_dim = strsplit(ref_dim_tmp);
dim_x=str2double(ref_dim{2});
dim_y=str2double(ref_dim{4});
dim_z=str2double(ref_dim{6});

h=waitbar(0,'Please wait');
for ROI_ind = 1:length(ROI_names)
    ROI_component_1 = dir(sprintf('%s%i*',ProbabilityMaskPath,ROI_codes{ROI_ind}(1)));
    ROI_probability_mask_output = sprintf('%s%s_probability_mask.nii.gz',OutputPath,ROI_names{ROI_ind});
    ROI_probability_mask_output_right = [ROI_probability_mask_output(1:end-7),'_right.nii.gz'];
    ROI_probability_mask_output_left = [ROI_probability_mask_output(1:end-7),'_left.nii.gz'];
    
    copyfile([ROI_component_1.folder,'/',ROI_component_1.name],ROI_probability_mask_output);
    % merge anatomical regions of the ROI using
    for ROI_component = ROI_codes{ROI_ind}
        if find(ROI_component == ROI_codes{ROI_ind}) > 1 % if this is not the first component
            ROI_component_dir = dir(sprintf('%s%i*',ProbabilityMaskPath,ROI_component));
            ROI_component_fullpath = [ROI_component_dir.folder,'/',ROI_component_dir.name];
            system(sprintf('fslmaths %s -add %s %s',ROI_component_fullpath,ROI_probability_mask_output,ROI_probability_mask_output));
        end
    end
    % Change unites to percentages
    system(sprintf('fslmaths %s -mul 0.01 %s',ROI_probability_mask_output,ROI_probability_mask_output));
    % Change resolution to reference functional image
    system(sprintf('flirt -in %s -ref %s  -applyxfm -usesqform -out %s',ROI_probability_mask_output,ref_functional,ROI_probability_mask_output));
    
    % split to left hemisphere (from x = 0 to x = dim_x/2)
    system(sprintf('fslmaths %s -roi 1 %i -1 -1 -1 -1 -1 -1 %s',ROI_probability_mask_output,floor(dim_x/2),ROI_probability_mask_output_left));
    % split to right hemisphere (from x = dim_x/2 to x = dim_x)
    system(sprintf('fslmaths %s -roi %i -1 -1 -1 -1 -1 -1 -1 %s',ROI_probability_mask_output,floor(dim_x/2 + 1),ROI_probability_mask_output_right));
       
%     % split to left hemisphere (from x = 0 to x = dim_x/2)
%     system(sprintf('fslroi %s %s 0 %i 0 %i 0 %i',ROI_probability_mask_output,ROI_probability_mask_output_left,floor(dim_x/2),dim_y,dim_z));
%     % split to right hemisphere (from x = dim_x/2 to x = dim_x)
%     system(sprintf('fslroi %s %s %i %i 0 %i 0 %i',ROI_probability_mask_output,ROI_probability_mask_output_right,floor(dim_x/2+1),dim_x,dim_y,dim_z));   
    
    % delete the merged ROI
    delete(ROI_probability_mask_output)
    waitbar(ROI_ind/length(ROI_names))
end
close(h)

% merge to complete ROI mask of all ROIs
ROI_merged_mask_output = sprintf('%s/merged_anatomy_ROI_mask.nii.gz',pwd);
copyfile([ROI_component_1.folder,'/',ROI_component_1.name],ROI_merged_mask_output);
h=waitbar(0,'Analyzing');
ROI_ind = 0;
for ROI_component = cell2mat(ROI_codes)
    ROI_ind = ROI_ind + 1;
    ROI_component_dir = dir(sprintf('%s%i*.nii.gz',ProbabilityMaskPath,ROI_component));
    ROI_component_fullpath = [ROI_component_dir.folder,'/',ROI_component_dir.name];
    system(sprintf('fslmaths %s -add %s %s',ROI_component_fullpath,ROI_merged_mask_output,ROI_merged_mask_output));
    waitbar(ROI_ind/length(cell2mat(ROI_codes)),h)
end
% Change resolution to reference functional image and binarize
system(sprintf('flirt -in %s -ref %s -applyxfm -usesqform -out %s',ROI_merged_mask_output,ref_functional,ROI_merged_mask_output));
system(sprintf('fslmaths %s -thr 0.01 -bin %s',ROI_merged_mask_output,ROI_merged_mask_output));
close(h)

