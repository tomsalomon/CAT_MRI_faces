%% open script: Define env and variables
clear;
close all;
tic

% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% Define these variables
ses_nums=[1,1,1,2,2];
task_nums=[1,2,3,1,3];
for analysis_i = 1:numel(task_nums)
    ses_num=ses_nums(analysis_i);
    task_num=task_nums(analysis_i);
    fprintf(['\n\nStarting Session %02i Task %02i\n',...
        '============================\n\n'],ses_num,task_num);
    
    if ses_num ==1
        Subjects=[2,4:14,16:17,19:25,27:41,43:44,46:49];
    elseif ses_num ==2
        Subjects=[2,4:5,8,10:12,14,17,20:23,27,29:31,33:36,38:40,44];
    end
    number_cores = 40;
    
    task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
    task_name=task_names{task_num};
    design_template=['design_group_',task_name,'_randomise_template.fsf'];
    ses_name = sprintf('ses-%02i',ses_num);
    c=clock;
    CurrentDate=sprintf('%i_%02.f_%02.f',c(1),c(2),c(3));
    output_path = sprintf(...
        '%s/../models/model001/ses-%02i/group_analysis/group_%s_%s_anatomical_ROI',...
        pwd,ses_num,task_name,CurrentDate);
    if isempty(dir(output_path))
        mkdir(output_path);
    end
    behave_data_path_ses1 = './../behavioral_data/';
    if ses_num==1
        behave_data_path = behave_data_path_ses1;
    else
        behave_data_path = [behave_data_path_ses1,'ses-02/'];
    end
    masks_path = [pwd,'/../models/masks_for_ROI'];
    ROI_names = {'ROI_01_vmPFC_right';'ROI_02_vmPFC_left';'ROI_03_hippocampus_right';'ROI_04_hippocampus_left';'ROI_05_SPL_right';'ROI_06_SPL_left';'ROI_07_striatum_right';'ROI_08_striatum_left'};
    contrast_name_lev3 = {'mean';'mod by probe effect'};
    
    masks = cell(numel(ROI_names),1);
    for ROI_i = 1:numel(ROI_names)
        masks{ROI_i} = niftiread([masks_path,'/',ROI_names{ROI_i}])~=0;
    end
    
    switch task_num
        case 1
            num_of_copes_lev1=27;
            contrast_name={'HV Go';'HV NoGo';'LV Go';'LV NoGo';'HV Neutral';'LV Neutral';'HV Sanity';'LV Sanity';'HV Go - Mod';'HV NoGo - Mod';'LV Go - Mod';'LV NoGo - Mod';'All - Mod by value';'All HV';'All LV';'HV minus LV';'All Go minus NoGo';'HV Go minus NoGo';'LV Go minus NoGo';'All Go minus NoGo - Mod';'HV Go minus NoGo - Mod';'LV Go minus NoGo - Mod';'All Go';'All Go - Mod';'All NoGo';'All NoGo - Mod';'All NoGo - with Neutral and Sanity'};
            contrast_fix_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,4,4,4,2,1,1,2,1,1,2,2,2,2,6];
            num_of_copes_lev2 = 5;
            contrast_name_lev2 ={'after > before';'before > after';'before';'after';'mean'};
            copes_lev2_2skip = [2,5];
            contrast_fix_lev2 = [1,1,1,1,2];
            baseline_2_max = 0.4075; % hight with double gamma - 2s stim
            
        case 2
            num_of_copes_lev1=25;
            contrast_name={'HV Go';'HV Go - by choice';'HV Go - by value';'HV Go - by GSD';'LV Go';'LV Go - by choice';'LV Go - by value';'LV Go - by GSD';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by value';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by value';'Go - missed';'NoGo - erroneous response';'NoGo - Sanity and fillers';'All Go - by RT';'HV Go > NoGo';'LV Go > NoGo';'All Go > NoGo';'All Go';'All NoGo';'All Go - by choice';'All NoGo - by choice';};
            contrast_fix_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2];
            num_of_copes_lev2 = 10;
            contrast_name_lev2 ={'scan1';'scan2';'scan3';'scan4';'scan5';'scan6';'scan7';'scan8';'last > first';'linear trend'};
            copes_lev2_2skip = [2:7];
            contrast_fix_lev2 = [1,1,1,1,1,1,1,1,1,10];
            baseline_2_max = 0.2088; % hight with double gamma - 1s stim
            
        case 3
            num_of_copes_lev1=26;
            contrast_name={'HV Go';'HV Go - by choice';'HV Go - by WTP diff';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by WTP diff';'HV - by RT';'LV Go';'LV Go - by choice';'LV Go - by WTP diff';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by WTP diff';'LV - by RT';'Sanity';'Missed trials';'HV chose Go > chose NoGo';'HV - chose Go > Chose NoGo - mod by choice';'LV - chose Go > Chose NoGo';'LV - chose Go >chose NoGo - mod by choice';'all - chose go > chose NoGo';'All - chose Go > Chose NoGo - mod by choice';'All Go';'All NoGo';'All Go modulated';'All NoGo Modulated'};
            contrast_fix_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2];
            num_of_copes_lev2 = 1;
            contrast_name_lev2 ={'mean'};
            copes_lev2_2skip = [];
            contrast_fix_lev2 = 1;
            baseline_2_max = 0.2088; % hight with double gamma - 1s stim
            
        case 4
            num_of_copes_lev1=[];
            contrast_name={ };
    end
    
    % initiate parallel computing
    if isempty(gcp('nocreate'))
        parpool(number_cores)
    end
    %% Multiply anatomical mask by BOLD data
    
    num_of_iterations = num_of_copes_lev1*(num_of_copes_lev2-length(copes_lev2_2skip))*length(Subjects)*length(ROI_names);
    parfor_progress(num_of_iterations);
    parfor cope = 1:num_of_copes_lev1
        for cope_lev2 = 1:num_of_copes_lev2
            if ismember(cope_lev2,copes_lev2_2skip) % skip uninteresting lev2 copes
                continue
            end
            cope_output_path = sprintf('%s/cope%i/cope%i',output_path,cope,cope_lev2);
            if ~isempty(cope_output_path)
                continue
            end
            
            mkdir(cope_output_path)
            scale_factor = (100 * baseline_2_max ^ 2) / (contrast_fix_lev1(cope) * contrast_fix_lev2(cope_lev2));
            for sub = Subjects
                sub_name = sprintf('sub-%03i',sub);
                sub_2_lev_cope = sprintf('%s/../%s/%s/model/model001/*%s.gfeat/cope%i.feat/stats/cope%i.nii.gz',...
                    pwd,sub_name,ses_name,task_name,cope,cope_lev2);
                sub_2_lev_mean_func = sprintf('%s/../%s/%s/model/model001/*%s.gfeat/cope%i.feat/mean_func.nii.gz',...
                    pwd,sub_name,ses_name,task_name,cope);
                
                for ROI_ind = 1:length(ROI_names)
                    parfor_progress;
                    %waitbar(progress/100,h,sprintf('Creating masks for cope %i out of %i\n%.2f%% done',cope,num_of_copes, progress))
                    ROI_name = ROI_names{ROI_ind};
                    ROI_mask_path = sprintf('%s/%s.nii.gz',masks_path,ROI_name);
                    if ~isempty(dir(ROI_mask_path))
                        output_file = sprintf('%s/%s_%s.nii.gz',cope_output_path,sub_name,ROI_name);
                        system(['fslmaths ',ROI_mask_path,' -mul ',sub_2_lev_cope,' -mul ',num2str(scale_factor),' -div ',sub_2_lev_mean_func,' ',output_file]);
                    end
                end
            end
        end
    end
    parfor_progress(0);
    results = cell(num_of_copes_lev1,num_of_copes_lev2);
    
    %% Read ROI data into matlab
    h = waitbar(0,'Extracting data from nifti files');
    progress = 0;
    for cope = 1:num_of_copes_lev1
        for cope_lev2 = 1:num_of_copes_lev2
            progress = progress + 1/(num_of_copes_lev2*num_of_copes_lev1);
            waitbar(progress,h);
            if ismember(cope_lev2,copes_lev2_2skip) % skip uninteresting lev2 copes
                continue
            end
            cope_output_path = sprintf('%s/cope%i/cope%i',output_path,cope,cope_lev2);
            output_files = dir([cope_output_path,'/sub*.nii.gz']);
            tmp2=cell(0);
            for ROI_i = 1:numel(ROI_names)
                output_files_ROI_ind = (contains({output_files.name},ROI_names{ROI_i}));
                tmp_output_files = output_files(output_files_ROI_ind);
                tmp_mask = masks{ROI_i};
                tmp1 = cell(length(tmp_output_files),1);
                parfor file_ind = 1:length(tmp_output_files)
                    try_again = 1;
                    while try_again
                        try
                            file_path = [tmp_output_files(file_ind).folder,'/', tmp_output_files(file_ind).name] ;
                            nifti_data_raw = niftiread(file_path);
                            nifti_data_no_zero = nifti_data_raw(tmp_mask);
                            nifti_data_mean = mean(nifti_data_no_zero);
                            % first cell - file name, second cell - non-zero data
                            tmp1{file_ind} = {tmp_output_files(file_ind).name, nifti_data_mean,nifti_data_no_zero};
                            try_again = 0;
                        catch
                            disp('failed to read nifti data. trying again')
                        end
                    end
                end
                tmp2=[tmp2;tmp1];
            end
            results{cope,cope_lev2}=tmp2;
        end
    end
    close(h)
    
    %% Merge results into one dataframe
    disp('Organizing data into one dataframe')
    disp('==================================')
    
    num_of_iterations = num_of_copes_lev1*num_of_copes_lev2;
    parfor_progress(num_of_iterations);
    results_mat = zeros(1,5);
    full_data = cell(1);
    parfor cope = 1:num_of_copes_lev1
        for cope_lev2 = 1:num_of_copes_lev2
            parfor_progress;
            if ismember(cope_lev2,copes_lev2_2skip) % skip uninteresting lev2 copes
                continue
            end
            
            % number of valid clusters with results
            num_clusters = length(results{cope,cope_lev2});
            for cluster = 1:num_clusters
                tmp_name = results{cope,cope_lev2}{cluster}{1};
                tmp_name_components = strsplit(tmp_name,{'sub-','_'});
                
                sub = str2double(tmp_name_components{2});
                ROI_ind = str2double(tmp_name_components{4});
                
                results_tmp = (results{cope,cope_lev2}{cluster}{2}); % Mean BOLD
                results_tmp(:,2) = sub; % sub code
                results_tmp(:,3) = ROI_ind;
                results_tmp(:,4) = cope_lev2;
                results_tmp(:,5) = cope;
                results_mat = [results_mat;results_tmp];
                %             progress = progress + 1/(num_clusters*num_of_copes_lev2*num_of_copes_lev1);
                %             waitbar(progress,h);
                full_data = [full_data;{results{cope,cope_lev2}{cluster}{3}}]
            end
        end
    end
    parfor_progress(0)
    results_mat(1,:)=[];
    full_data(1)=[];
    
    % Save results in a table
    results_table = array2table(results_mat,'VariableNames',...
        {'BOLD','sub','ROI','cope_lev2','cope_lev1'});
    results_table.sub = nominal(results_table.sub);
    results_table.BOLD = double(results_table.BOLD);
    results_table.cope_lev1_str = contrast_name(results_table.cope_lev1); % add cope titles
    results_table.full_data = full_data;
    results_table.ROI_size = cellfun(@length,results_table.full_data);
    
    %% Finish script: Save results and close parallel allocation
    % save statistics results
    save([output_path,'/results.mat'],'results_table');
    save([output_path,'/results_workspace.mat']);
    
end
