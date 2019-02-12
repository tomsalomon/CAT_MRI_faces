%% On Server
% create environment in order to be able to run FSL from Matlab
setenv('FSLDIR','/share/apps/fsl/'); %the FSL folder
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %the output type
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

cd ..
addpath(genpath('/export/home/DATA/schonberglab/Michal_Pred'));

outdir = '/export/home/DATA/schonberglab/Michal_Pred/MRI_faces_analysis/localizer_face_clusters'; % dir to save face clusters
anatomic_masks_mainpath = '/export/home/DATA/schonberglab/Michal_Pred/MRI_faces_analysis/anatomic_face_clusters'; % path for face perception masks

experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives'; % path for experiment
addpath(experiment_path);
%% ______________________________________________________________
ses_num='1';
task = 'localizer';
cope = '3';
zstat = '1';
task_path = 'task-localizer.gfeat/cope3.feat/cluster_mask_zstat1.nii.gz';
sub_path = dir([experiment_path,'/sub*']);
nSubs=length(sub_path);
anatomic_masks_path = dir([anatomic_masks_mainpath,'/','*nii.gz*']);
nMasks = length(anatomic_masks_path);
anatomic_masks_names = cell(nMasks,1);
% find masks paths
for k = 1:nMasks
    a = strsplit(anatomic_masks_path(k).name,'.nii.gz');
    anatomic_masks_names{k} = a{1};
end
%% multiply each subject clusters mask with each anatomic mask
for i = 1:nSubs % loop over subjects
    strcat('sub_',num2str(i),'/',num2str(nSubs))
    full_sub_folder = [experiment_path,'/',sub_path(i).name,'/ses-0',ses_num,'/model/model001/'];
    full_sub_path = [full_sub_folder,strcat(sub_path(i).name,'_ses-0',ses_num,'_',task_path)];
    addpath(full_sub_folder);
   
    if~exist([outdir,'/',sub_path(i).name],'dir')
        system(['mkdir ' [outdir,'/',sub_path(i).name]])
    end
    if~exist([outdir,'/',sub_path(i).name,'/ses-0',ses_num],'dir')
        system(['mkdir ' [outdir,'/',sub_path(i).name,'/ses-0',ses_num]])
    end
    
    openfile = gunzip(full_sub_path,outdir);
    sub_data = niftiread(openfile{1});

    for j = 1:nMasks % loop over masks
        strcat('mask_',num2str(j),'/',num2str(nMasks))
        mask_path = [anatomic_masks_mainpath,'/',anatomic_masks_path(j).name];        
        new_sub_path1 = [outdir,'/',sub_path(i).name,'/ses-0',ses_num,'/',anatomic_masks_names{j},'_',task,'_cope',cope,'_cluster_mask_',zstat,'.nii'];
        %         new_sub_path2 = [outdir,'/',sub_path(i).name,'/ses-0',ses_num,'/',anatomic_masks_names{j},'_',task,'_cope',cope,'_cluster_mask_',zstat,'.nii.gz'];
        %         new_sub_path3 = [outdir,'/',sub_path(i).name,'/ses-0',ses_num,'/',anatomic_masks_names{j},'_',task,'_cope',cope,'_cluster_mask_',zstat,'bin.nii.gz'];
        
        if~exist(new_sub_path1,'file') % mask has not been created yet
            openmask = gunzip(mask_path,anatomic_masks_mainpath);
            mask = niftiread(openmask{1});
                        
            masked_data = double(mask).*double(sub_data);
            vals = unique(masked_data); % values of clusters in the mask ROI
            info_test=niftiinfo(openfile{1});
            if isempty(find(vals, 1)) %in case there is no intersection
                % niftiwrite(int32(masked_data),new_sub_path1,info_test); % save zeros mat
                % gzip(new_sub_path1);
            else
                vals(vals==0)=[]; % remove the zreo value
                new_mask=ismember(sub_data,vals); % choose voxels with the numbers of clusters partially on the intersection 
                niftiwrite(int32(new_mask),new_sub_path1,info_test);% save result
                gzip(new_sub_path1);
            end
            system(['rm ',openmask{1}])% remove the unneeded opened mask *nii file
            system(['rm ',new_sub_path1])% remove the unneeded unzipped new mask created *nii file  
        end
    end
    system(['rm ',openfile{1}])% remove the unneeded opened subject data *nii file
end