%% Creating anatomic ROIs
% 
% create environment in order to be able to run FSL from Matlab
setenv('FSLDIR','/share/apps/fsl/'); %the FSL folder
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %the output type
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

cd .. 
% addpath(genpath('/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/'));
addpath(genpath('/export/home/DATA/schonberglab/Michal_Pred'));

%% load harvard oxford atlas
experiment_path = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives';
masksfolder = '/export/home/DATA/schonberglab/Michal_Pred/anatomic_masks';
sub_masksfolder = '/export/home/DATA/schonberglab/Michal_Pred/anatomic_masks/subcortical_masks';

addpath(genpath(masksfolder));
outdir = '/export/home/DATA/schonberglab/Michal_Pred/MRI_faces_analysis/anatomic_face_clusters';

ref_folder = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/sub-001/ses-01/model/model001/sub-001_ses-01_task-localizer.gfeat/cope3.feat/'; 
ref_res = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/sub-001/ses-01/model/model001/sub-001_ses-01_task-localizer.gfeat/cope3.feat/cluster_mask_zstat1.nii.gz'; 
addpath(genpath(ref_folder));
%% create face regions masks struct
% sys - refers to main or extended face perception region
% mask - is the 3D binary mask in subjects resolution and mni coordunate system
% name - is the name of the system
% region - is the numbers of anatomc regions in the HarvardOxford atlas
% relevant to the perception region
%% main face perception system
face_regions = struct;
face_regions.mask = [];
face_regions(1).sys = 'main';
face_regions(1).name = 'sts';
face_regions(1).region = [10,12]; % superior temporal gyrus and middle temporal gyrus both posterior division
face_regions(2).sys = 'main';
face_regions(2).name = 'ffa';
face_regions(2).region = [16,39]; % inferior temporal gyrus occi. and temporal occipital fusiform cortex
face_regions(3).sys = 'main';
face_regions(3).name = 'ofa';
face_regions(3).region = [23,40]; % lateral occipital cortex infirior division and occipital fuziform gyrus 
%% extended system
face_regions(4).sys = 'ext';
face_regions(4).name = 'amig';
face_regions(4).region = [10,20]; % left and right amygdala from *subcortical* atlas
face_regions(5).sys = 'ext';
face_regions(5).name = 'ifg';
face_regions(5).region = [1,6]; % frontal pole and inferior frontal gyrus pars opercularis
face_regions(6).sys = 'ext';
face_regions(6).name = 'msts';
face_regions(6).region = [9,11]; % superior temporal gyrus and middle temporal gyrus both anterior division
face_regions(7).sys = 'ext';
face_regions(7).name = 'prec';
face_regions(7).region = [30,31]; % cingulate gyrus posterior division and precuneous cortex
face_regions(8).sys = 'ext';
face_regions(8).name = 'apc'; 
face_regions(8).region = 28; % paracingulate gyrus
face_regions(9).sys = 'main';
face_regions(9).name = 'main_sys';
face_regions(9).region = [10,12,16,23,39,40]; %all main system
face_regions(10).sys = 'ext';
face_regions(10).name = 'ext_sys';
face_regions(10).region = [1,6,9,11,28,30,31]; % all extended system
nMasks = length(face_regions);
anatomic_masks_path = '/export/home/DATA/schonberglab/Michal_Pred/anatomic_masks';
anatomic_masks_path_sub = '/export/home/DATA/schonberglab/Michal_Pred/anatomic_masks/subcortical_masks';

%% create anatomic face regions masks
% sum up relevant anatomic regions to stand for a face perception region 
for i = 5:7%length(nMasks)
    strcat(num2str(i),'/',num2str(nMasks))
    maskpath = fullfile(outdir,[face_regions(i).name,'.nii.gz']);
    regions = face_regions(i).region;
    regionspaths = cell(1,length(regions));
    for k= 1:length(regions)
        regionspaths{k} = [anatomic_masks_path, '/mask_',num2str(regions(k)),'_mni_bin.nii.gz'];
    end
    system(['fslmaths /export/home/DATA/schonberglab/Michal_Pred/MRI_faces_analysis/anatomic_face_clusters/ext_sys_temp.nii.gz -add /export/home/DATA/schonberglab/Michal_Pred/MRI_faces_analysis/anatomic_face_clusters/amig.nii.gz -bin ',maskpath])
    % THIS PART NEEDS TO CHANGE ACCORDING TO NUMBER OF REGIONSs
    system(['fslmaths ',regionspaths{1},' -add ',regionspaths{2},' -add ',regionspaths{3},' -add ',regionspaths{4},' -add ',regionspaths{5},' -add ',regionspaths{6},' -add ',regionspaths{7},' -bin ',maskpath]) %
end
%% save masks on struct
outdir = '/export/home/DATA/schonberglab/Michal_Pred/MRI_faces_analysis/anatomic_face_clusters';
for i = 1:nMasks
    openmask = gunzip(fullfile(outdir,[face_regions(4).name,'.nii.gz']),outdir);
    face_regions(i).mask = niftiread(openmask{1});
end
save('/export/home/DATA/schonberglab/Michal_Pred/MRI_faces_analysis/anatomic_face_clusters/face_regions.mat','face_regions');