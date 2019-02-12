% this function creates the ppi regressors for all participants, sessions
% and runs of the response to snacks task
% if you want just some of the paricipants, input the numbers as first
% argument as a vector. I you want all- input nothing or an empty vector []
% as the first input argument.
% If you want just some of the sessions, input it as second argument as a
% cell array. For all sessions input nothing or an empty cell ({}) in the second argument.
% 3rd input argument is the suffix of the seed rois filenames. Default is
% 'sphere8_mul_brain_mask.nii.gz'
%
% DEPENDENCIES (from Jeanette):
% fsl_ppi.m
% fsldesign_to_spmsess.m
% read_fsl_design.m
% spm_PEB.m
% designconvert.sed
% BBR.m - if you use 'BBR' method in your des
%
% was created by Rotem Botvinik Nezer on January 2018
% basd on codes from Jeanette Mumford
% Modified by Tom Salomon, November 2018

clear
close all;
tic

%% define these variables
session_num =1 ;
seed_ROI={'vmPFC','Striatum','z','FFA_left','STS_right','STS_left'};
is_localizer_ROI = [0, 0, 1, 1, 1, 1];
main_path = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives'; % or [pwd,'/..']
ppi_path = [main_path,'/models/masks_for_PPI'];
task_num=2;
number_cores = 25;

% contrasts of interest
switch task_num
    case 2
        [contrast_all_go,contrast_all_nogo] = deal(zeros(1,18));
        contrast_all_go([1,5]) = 1; % all go items
        contrast_all_nogo([9,12]) = 1; % all nogo items (in probe)
end

%% Initiate script
if isempty(gcp('nocreate')) % open parallel processing pool
    parpool(number_cores)
end

task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
num_of_runs_per_task=[2,8,4,2;1,0,4,2];
num_of_runs=num_of_runs_per_task(session_num,task_num);
task_name=task_names{task_num};
design_template=['design_sub-001_',task_name,'.fsf'];
ses_name=['ses-',num2str(session_num,'%02i')];
designs_dir=['./../models/model001/',ses_name,'/designs/'];
ses_name=['ses-',num2str(session_num,'%02i')];
model_name_origin = 'model001'; % onsets of the original task will be copied from this model
% add spm path and current folder
spm5_path = '/share/apps/spm/spm5';
addpath(spm5_path);
addpath(pwd)

% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

switch session_num
    case 1
        subjects=[2,4:14,16:17,19:25,27:41,43:49];
        subjects = 1:50;
    case 2
        subjects=[2,4:5,8,10:12,14,17,20:23,27,29:31,33:36,38:40,44];
end

parfor_progress(numel(subjects));

parfor sub_i = 1:numel(subjects)
    sub=subjects(sub_i);
    sub_name=sprintf('sub-%03i',sub);
    for seed_i = 1:numel(seed_ROI)
        model_name = sprintf('model%03i',seed_i+1);
        seed_ROI_name = seed_ROI{seed_i};
        
        % skip subject for which the seed was not identified
        if is_localizer_ROI(seed_i)
            seed_rois = dir([ppi_path,'/',sub_name,'_',seed_ROI_name,'*']);
        else
            seed_rois = dir([ppi_path,'/',seed_ROI_name,'*']);
        end
        if isempty(seed_rois)
            continue
        end
        seed_roi_filename = seed_rois.name;
        
        for run_i = 1:num_of_runs
            run_name = sprintf('run-%02i',run_i);
            path_for_txt_file = [main_path '/' sub_name '/' ses_name '/model/',model_name,'/onsets/' task_name,'_' run_name];
            path_for_txt_file_origin = strrep(path_for_txt_file,model_name,model_name_origin);
            if isfolder(path_for_txt_file)
                system(['rm -r --interactive=never ',path_for_txt_file]);
            end
            mkdir(path_for_txt_file)
            system(sprintf('cp %s/* %s/',path_for_txt_file_origin, path_for_txt_file));
            time_series_txt_full_filename = [path_for_txt_file '/seed_mean_ts.txt'];
            mask_img = [ppi_path '/' seed_roi_filename];
            input_img = [main_path '/' sub_name '/' ses_name '/' sub_name '_' ses_name '_',task_name,'_',run_name,'_bold_space-MNI152NLin2009cAsym_preproc_brain.nii.gz'];
            % calculate and save mean time-series to txt file
            system(['fslmeants -i ' input_img ' -m ' mask_img ' -o ' time_series_txt_full_filename]);
%             % scale down the scanner arbitrary units
%             meants_data = csvread(time_series_txt_full_filename).*1e-4;
%             csvwrite(time_series_txt_full_filename,meants_data);
            % define feat dir (of GLM prior to ppi)
            featdir = [main_path '/' sub_name '/' ses_name '/model/model001/' sub_name '_' ses_name '_',task_name,'_',run_name '.feat'];
            
            %% create ppi regressors for all go vs. nogo items
            % put 1 in the 4th input for fsl_ppi to see the plots- only
            % if you run a few otherwise you'll get MANY figures...
            %creating regressor all_go
            [PPI_all_go,design1_all_go] = fsl_ppi(featdir,time_series_txt_full_filename,contrast_all_go,0);
            %creating regressor all_nogo
            [PPI_all_nogo,design2_all_nogo] = fsl_ppi(featdir,time_series_txt_full_filename,contrast_all_nogo,0);
            
            %These are already convolved, so use 1 column format with *NO* HRF convolution in FSL.
            ppi_all_go=PPI_all_go.ppi;
            ppi_all_nogo=PPI_all_nogo.ppi;
            
            % save the regressors
            csvwrite([path_for_txt_file '/ppi_regressor_all_go.txt'], ppi_all_go)
            csvwrite([path_for_txt_file '/ppi_regressor_all_nogo.txt'], ppi_all_nogo)
            
        end
    end
    parfor_progress();
end
parfor_progress(0);

time_it_took = toc;
disp(['done in ' num2str(time_it_took) 'secs']);

