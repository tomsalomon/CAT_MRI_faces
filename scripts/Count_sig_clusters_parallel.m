clear;

% Define these variables
task_num=1;
ses_num=2;
experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/';
group_analysis_path=[experiment_path,'models/model001/ses-',sprintf('%02.f',ses_num),'/group_analysis/'];
zthresh='SVC_04'; %2.3; 3.1 or 'randomise' or 'SVC'
number_cores = 26;

% initiate parallel computing
test_pool_open = gcp('nocreate');
if isempty(test_pool_open)
    parpool(number_cores)
end
% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

switch task_num
    case 1
        task_name='task-responsetostim';
        num_of_level1_copes=27;
        num_of_level2_copes=5;
        num_of_level3_copes=4;
    case 2
        task_name='task-training';
        num_of_level1_copes=25;
        num_of_level2_copes=10;
        num_of_level3_copes=4;
    case 3
        task_name='task-probe';
        num_of_level1_copes=26;
        num_of_level2_copes=1;
        num_of_level3_copes=4;
    case 4
        task_name='task-localizer';
        num_of_level1_copes=[];
end
if isnumeric(zthresh)
thresh_name=strrep(num2str(zthresh),'.','_');
else
 thresh_name=zthresh;   
end

cope_lev_1=repmat(1:num_of_level1_copes,[1,num_of_level2_copes*num_of_level3_copes]);
cope_lev_1=cope_lev_1(:);
cope_lev_2=repmat(1:num_of_level2_copes,[num_of_level1_copes,num_of_level3_copes]);
cope_lev_2=cope_lev_2(:);
cope_lev_3=repmat(1:num_of_level3_copes,[num_of_level1_copes*num_of_level2_copes,1]);
cope_lev_3=cope_lev_3(:);

results=[cope_lev_1,cope_lev_2,cope_lev_3,zeros(size(cope_lev_1))];
analysis_path_options=dir([group_analysis_path,'group_',task_name,'*',thresh_name,'*']);
if isempty(analysis_path_options)
    error('Error: no results directory found. please make sure the paths are correctly defined')
elseif length(analysis_path_options)==1
analysis_dir_selection=1;
else
analysis_dir_selection = listdlg('PromptString','Select an analysis directory:','SelectionMode','single','ListString',{analysis_path_options.name},'ListSize',[500,400]);
end
analysis_path=[group_analysis_path,analysis_path_options(analysis_dir_selection).name];

%analysis_progress=0;
%h = waitbar(analysis_progress,'Analyzing..');
parfor_progress(length(cope_lev_1));

parfor ind=1:length(cope_lev_1)
    nii_image=[analysis_path,sprintf('/cope%i.gfeat/cope%i.feat/cluster_mask_zstat%i.nii.gz',cope_lev_1(ind),cope_lev_2(ind),cope_lev_3(ind))];
    %change this!!!!
    if~isempty(dir(nii_image))
        [~,tmp]=system(['fslstats ',nii_image,' -p 100']);
        results(ind,4)=str2double(tmp);
    else
        results(ind,4)=nan;
    end
    %analysis_progress=ind/length(cope_lev_1);
    %waitbar(analysis_progress,h);
    parfor_progress();
end
    parfor_progress(0);

% close parallel pool
%delete(gcp('nocreate'));
%close(h)


