clear;

% Define these variables
task_num=2;
ses_num=1;
models = 2:7; % 2:7 for PPI models
zthresh='2.3'; %2.3; 3.1 or 'randomise' or 'SVC'
number_cores = 26;
experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives';

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
    case 2
        task_name='task-training';
        num_of_seeds=length(models); % only one relevant level 1 cope: cope 1 - PPI All Go > NoGo
        num_of_level2_copes=3;
        num_of_level3_copes=4;
end
if isnumeric(zthresh)
    thresh_name=strrep(num2str(zthresh),'.','_');
else
    thresh_name=zthresh;
end

model=repmat(models,[1,num_of_level2_copes*num_of_level3_copes]);
model=model(:);
cope_lev_1 = ones(size(model))
cope_lev_2=repmat(1:num_of_level2_copes,[num_of_seeds,num_of_level3_copes]);
cope_lev_2=cope_lev_2(:);
cope_lev_3=repmat(1:num_of_level3_copes,[num_of_seeds*num_of_level2_copes,1]);
cope_lev_3=cope_lev_3(:);


results=[model,cope_lev_2,cope_lev_3,zeros(size(model))];

%analysis_progress=0;
%h = waitbar(analysis_progress,'Analyzing..');
parfor_progress(length(model));

for ind=1:length(model)
    group_analysis_path=sprintf('%s/models/model00%i/ses-%02.f/group_analysis/',experiment_path,model(ind),ses_num);
    analysis_path_options=dir([group_analysis_path,'group_',task_name,'*']);
    if isempty(analysis_path_options)
        error('Error: no results directory found. please make sure the paths are correctly defined')
    elseif length(analysis_path_options)==1
        analysis_dir_selection=1;
    end
    analysis_path=[group_analysis_path,analysis_path_options(analysis_dir_selection).name];
    nii_image=[analysis_path,sprintf('/cope1.gfeat/cope%i.feat/cluster_mask_zstat%i.nii.gz',cope_lev_2(ind),cope_lev_3(ind))];
    %change this!!!!
    if~isempty(dir(nii_image))
        [~,tmp]=system(['fslstats ',nii_image,' -p 100']);
        results(ind,4)=str2double(tmp);
    else
        results(ind,4)=nan;
    end
    %analysis_progress=ind/length(cope_lev_1);
    %waitbar(analysis_progress,h);s
    parfor_progress();
end
parfor_progress(0);
% close parallel pool
%delete(gcp('nocreate'));
%close(h)


