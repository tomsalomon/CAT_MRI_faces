

clear
close all

cortical_atlas_path='/export/share/apps/fsl/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-1mm.nii.gz';
subcortical_atlas_path='/export/share/apps/fsl/data/atlases/HarvardOxford/HarvardOxford-sub-maxprob-thr25-1mm.nii.gz';
standard = '/export/share/apps/fsl/data/standard/MNI152_T1_0.5mm.nii.gz';
experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/';
masks_path = [experiment_path, 'models/masks_for_SVC'];
output_path= [experiment_path,'figures/SVC/'];

% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

masks = dir([masks_path,'/0*']);
for mask_i = 1:numel(masks)
    mask_name = masks(mask_i).name;
    origin_mask = [masks_path,'/',mask_name];
    output_mask = [output_path,'/',mask_name];
    system(sprintf('flirt -in %s -ref %s -applyxfm -usesqform -out %s',...
        origin_mask,standard,output_mask));
    system(sprintf('fslmaths %s -uthr 0.8 %s',...
        output_mask,output_mask));
end






% 
% % How SVC masks can be created
% 
% % create zero mask
% system(sprintf('fslmaths %s -mul 0 %s/zero_mask.nii.gz',subcortical_atlas_path, output_path));
% zero_mask=[output_path,'/zero_mask.nii.gz'];
% 
% % create mask for left and right striatum
% % regions form atlas are: 5 (left caudate)  6 (left putamen)  11 (left accumbens) 16 (right caudate) 17 (right putamen) 21 (right accumbens)
% region_name='striatum';
% mask_file=[output_path,'/',region_name,'_mask'];
% system(sprintf('fslmaths %s -mul 0 %s',subcortical_atlas_path,mask_file));
% for atlas_region_num = [5 6 11 16 17 21]
%     
%     filename=sprintf('%s/%s_region_%i.nii.gz',output_path,region_name,atlas_region_num);
%     
%     system(sprintf('fslmaths %s -thr %i -uthr %i -bin %s',...
%         subcortical_atlas_path, atlas_region_num,atlas_region_num,filename))
%     % add to the combined mask
%     system(sprintf('fslmaths %s -add %s -bin %s',...
%         filename, mask_file, mask_file));
% end
% % convert voxel dimensions
% new_filename=[mask_file,'_0.5mm'];
% system(sprintf('flirt -in %s -ref %s -applyxfm -usesqform -out %s',...
%     mask_file,standard,new_filename));
% 
