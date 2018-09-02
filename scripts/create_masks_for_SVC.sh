#!/bin/sh

cortical_atlas_path=/export/share/apps/fsl/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-2mm.nii.gz
subcortical_atlas_path=/export/share/apps/fsl/data/atlases/HarvardOxford/HarvardOxford-sub-maxprob-thr25-2mm.nii.gz

masks_path=/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/models/model001/masks_for_SVM/

# create zero mask
fslmaths ${subcortical_atlas_path} -mul 0 ${masks_path}/zero_mask.nii.gz
zero_mask=${masks_path}/zero_mask.nii.gz

# create mask for left and right striatum
# regions form atlas are: 5 (left caudate)  6 (left putamen)  11 (left accumbens) 16 (right caudate) 17 (right putamen) 21 (right accumbens)
region_name=striatum
mask_file=${masks_path}/${region_name}_mask
fslmaths ${subcortical_atlas_path} -mul 0 ${mask_file}
for atlas_region_num in 5 6 11 16 17 21
do
    filename=${masks_path}/${region_name}_region_${atlas_region_num}.nii.gz
    fslmaths ${subcortical_atlas_path} -thr ${atlas_region_num} -uthr ${atlas_region_num} -bin ${filename}
# add to the combined mask
    fslmaths ${filename} -add ${mask_file} -bin ${mask_file}
done
# convert to our fmri voxel dimensions
new_filename=${mask_file}_our_fmri_voxel_dim
flirt -in ${mask_file} -ref /export/home/DATA/schonberglab/MRI_snacks/analysis/bids/derivatives/model/model001/group/responsetosnacks/after_before/cope18_zthresh23.gfeat/cope1.feat/thresh_zstat1.nii.gz -applyxfm -usesqform -out ${new_filename}
fslmaths  ${new_filename} -thr 0.5 -bin ${new_filename}

# create mask for left and right SPL
# regions form atlas are: 18 (bilateral)
region_name=SPL
mask_file=${masks_path}/${region_name}_mask
fslmaths ${cortical_atlas_path} -mul 0 ${mask_file}
for atlas_region_num in 18
do
    filename=${masks_path}/${region_name}_region_${atlas_region_num}.nii.gz
    fslmaths ${cortical_atlas_path} -thr ${atlas_region_num} -uthr ${atlas_region_num} -bin ${filename}
# add to the combined mask
    fslmaths ${filename} -add ${mask_file} -bin ${mask_file}
done
# convert to our fmri voxel dimensions
new_filename=${mask_file}_our_fmri_voxel_dim
flirt -in ${mask_file} -ref /export/home/DATA/schonberglab/MRI_snacks/analysis/bids/derivatives/model/model001/group/responsetosnacks/after_before/cope18_zthresh23.gfeat/cope1.feat/thresh_zstat1.nii.gz -applyxfm -usesqform -out ${new_filename}
fslmaths  ${new_filename} -thr 0.5 -bin ${new_filename}



