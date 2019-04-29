clear

% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

rois =dir ('./roi*.nii.gz');
 roi_dat = niftiread(rois(1).name);
 all_roi = roi_dat*0;
 
for i = 1:numel(rois)
    roi_dat = niftiread(rois(i).name)*i;
    all_roi = all_roi +roi_dat;
    disp(i)
end

info = niftiinfo(rois(i).name);
niftiwrite(all_roi,'test',info,'Compressed',1)