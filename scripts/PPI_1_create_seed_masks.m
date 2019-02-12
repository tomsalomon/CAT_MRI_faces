

%% open script: Define env and variables
clear;
close all;
tic

ses_num =1;
ROI_name = {'FFA_right','FFA_left','STS_right','STS_left'};
PPI_mask_path = './../models/masks_for_PPI/';
task_name = 'localizer';
cope = 3; % first level contrast of interest
number_cores = 30;
sphere_size = 5;

% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% initiate parallel computing
if isempty(gcp('nocreate'))
    parpool(number_cores)
end

if ses_num ==1
    Subjects=[2,4:14,16:17,19:25,27:41,43:49];
elseif ses_num ==2
    Subjects=[2,4:5,8,10:12,14,17,20:23,27,29:31,33:36,38:40,44];
end
ses_name =  sprintf('ses-%02i',ses_num);
parfor_progress(numel(Subjects));

%% functional face localizer ROI
parfor sub_i = 1:numel (Subjects)
    sub=Subjects(sub_i);
    sub_name = sprintf('sub-%03i',sub);
    for ROI_i = 1:numel(ROI_name)
        ROI_path_data = dir(sprintf('%s/face_localizer/Functional_ROI/%s/*%s.nii.gz',...
            pwd,sub_name,ROI_name{ROI_i}));
        
        if ~isempty(ROI_path_data)
            ROI_path = [ROI_path_data.folder,'/',ROI_path_data.name];
            ROI_name_tmp = ROI_path_data.name;
            % find peak activation:
            % create masked z image
            ROI_z_path = [ROI_path_data.folder,'/',ROI_name_tmp,'_Zstat.nii.gz'];
            system(sprintf('fslmaths %s/zstat.nii.gz -mul %s %s',...
                ROI_path_data.folder,ROI_path,ROI_z_path));
            % find peak coordinates with FSL's cluster
            [~,cluster_info] = system(sprintf('cluster -i %s -t 2.3',ROI_z_path));
            line_breaks = strfind(cluster_info,newline);
            cluster_info_short = cluster_info(min(line_breaks)+1:max(line_breaks)-1);
            cluster_info_delim = strsplit(cluster_info_short);
            max_voxel = str2double(cluster_info_delim(4:6)); % peak (native space)
            
            % create sphere around the peak
            ROI_sphere_path = [ROI_path_data.folder,'/',ROI_name_tmp,'_sphere.nii.gz'];
            system(sprintf('fslmaths %s -mul 0 -add 1 -roi %i 1 %i 1 %i 1 0 1 %s',...
                ROI_z_path,max_voxel(1),max_voxel(2),max_voxel(3),ROI_sphere_path));
            system(sprintf('fslmaths %s -kernel sphere %i -fmean -bin %s',...
                ROI_sphere_path,sphere_size,ROI_sphere_path));
            % create trimmed sphere using the original cluster
            ROI_sphere_trimmed_path = [ROI_path_data.folder,'/',ROI_name_tmp,'_sphere_trimmed.nii.gz'];
            system(sprintf('fslmaths %s -mul %s %s',...
                ROI_sphere_path,ROI_path,ROI_sphere_trimmed_path));
            copyfile(ROI_sphere_trimmed_path,sprintf('%s/%s_%s.nii.gz',PPI_mask_path,sub_name,ROI_name{ROI_i}));
        end
    end
    parfor_progress();
end
parfor_progress(0);

%% anatomical ROI
ROI_name_anat = {'vmPFC','Striatum'};
activations_path = './../models/masks_for_PPI/activations/';
for ROI_i = 1:numel(ROI_name_anat)
    ROI_path_data = dir(sprintf('%s/*%s.nii.gz',...
        activations_path,ROI_name_anat{ROI_i}));
    ROI_path = [ROI_path_data.folder,'/',ROI_path_data.name];
    ROI_name_tmp = ROI_path_data.name;
    % find peak activation:
    
    % find peak coordinates with FSL's cluster
    [~,cluster_info] = system(sprintf('cluster -i %s -t 2',ROI_path));
    line_breaks = strfind(cluster_info,newline);
    cluster_info_short = cluster_info(min(line_breaks)+1:max(line_breaks)-1);
    cluster_info_delim = strsplit(cluster_info_short);
    max_voxel = str2double(cluster_info_delim(4:6)); % peak (native space)
    
    % create sphere around the peak
    ROI_sphere_path = [ROI_path_data.folder,'/',ROI_name_tmp,'_sphere.nii.gz'];
    system(sprintf('fslmaths %s -mul 0 -add 1 -roi %i 1 %i 1 %i 1 0 1 %s',...
        ROI_path,max_voxel(1),max_voxel(2),max_voxel(3),ROI_sphere_path));
    system(sprintf('fslmaths %s -kernel sphere %i -fmean -bin %s',...
        ROI_sphere_path,sphere_size,ROI_sphere_path));
    % create trimmed sphere using the original cluster
    ROI_sphere_trimmed_path = [ROI_path_data.folder,'/',ROI_name_tmp,'_sphere_trimmed.nii.gz'];
    system(sprintf('fslmaths %s -mul %s -bin %s',...
        ROI_sphere_path,ROI_path,ROI_sphere_trimmed_path));
    copyfile(ROI_sphere_trimmed_path,sprintf('%s/%s.nii.gz',PPI_mask_path,ROI_name_anat{ROI_i}));
end

%% Descriptive statistics for the PPI seed masks
files =dir([PPI_mask_path,'./*.nii.gz']);
sizes = nan(numel(files),1);
for i = 1:numel(files)
    file = [files(i).folder,'/',files(i).name];
    [~,cluster_info] = system(sprintf('cluster -i %s -t 0.1',file));
        line_breaks = strfind(cluster_info,newline);
    cluster_info_short = cluster_info(min(line_breaks)+1:max(line_breaks)-1);
    cluster_info_delim = strsplit(cluster_info_short);
    sizes(i) = str2double(cluster_info_delim(2)); % peak (native space)
end

AllROI = [ROI_name_anat,ROI_name];
ROI_ind=nan(numel(files),1);

for i=1:numel(AllROI)
   ROI_ind(contains({files.name},AllROI{i},'IgnoreCase',1)) = i;
   fprintf('\nROI: %s;\tmean seed size = %.2f, SD = %.2f',...
    AllROI{i},mean(sizes(ROI_ind==i)),std(sizes(sizes(ROI_ind==i))));
end
 
figure
gscatter(ROI_ind,sizes,ROI_ind)
legend(AllROI{:},'interpreter','none')
desc_txt = fprintf(['\n\nDescriptive Statistics\n=======================\n',...
    'mean seed size = %.2f, SD = %.2f, range = %i - %i\n'],...
    mean(sizes),std(sizes),min(sizes),max(sizes));
disp(desc_txt)
figure;
histogram(sizes,10)
xlabel('PPI seed size')

