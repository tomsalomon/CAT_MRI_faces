% This code uses probability ROI masks based on anatomical and results from
% the functional localizer to create a functional ROI mask.

clear;
close all;

% create environment in order to be able to run FSL from Matlab
setenv('FSLDIR','/share/apps/fsl/'); %the FSL folder
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %the output type
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% Define the following variables
subjects = 1:50;
session = 1;
model_name = 'model001';
task_name = 'task-localizer';
cope = 3;
main_path = [pwd,'/../../'];
ROI_anat_path = [pwd,'/Anatomical_ROI/'];
merged_anat_mask = [pwd,'/merged_anatomy_ROI_mask.nii.gz'];
min_prop_2b_included = 0.05; % min prop of cluster that need to be within the anatomy mask

ses_name = sprintf('ses-%02i',session);
cope_name = sprintf('cope%i',cope);
ROI = dir([ROI_anat_path,'*.nii.gz']);
num_ROIs = length(ROI);
cluster_means = cell(length(subjects),1);
cluster_means_norm = cell(length(subjects),1);

ROI_center_mass = cell(num_ROIs,1);
for ROI_i = 1:num_ROIs
    [~,ROI_center_mass{ROI_i}]=system_numeric_output(sprintf('fslstats %s/%s -c',ROI(ROI_i).folder,ROI(ROI_i).name));
    ROI_center_mass{ROI_i}(4)=[];
    ROI_center_mass{ROI_i}=round(ROI_center_mass{ROI_i},0);
end

h = waitbar (0,'Analyzing....');
for subject = subjects
    sub_name =  sprintf('sub-%03i',subject);
    sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
    
    feat_path = [main_path,sub_name,'/',ses_name,'/model/',model_name,'/',sub_name,'_',ses_name,'_',task_name,'.gfeat/',cope_name,'.feat/'];
    thresh_zstat_path_origin= [feat_path,'/thresh_zstat1.nii.gz'];
    cluster_mask_path_origin= [feat_path,'/cluster_mask_zstat1.nii.gz'];
    
    thresh_zstat_path= [sub_path,'thresh_zstat.nii.gz'];
    cluster_mask_path= [sub_path,'cluster_mask.nii.gz'];
    cluster_valid_mask_path= [sub_path,'cluster_valid_mask.nii.gz'];
    
    if isempty(dir(sub_path))
        mkdir(sub_path)
        copyfile(thresh_zstat_path_origin,thresh_zstat_path);
        copyfile(cluster_mask_path_origin,cluster_mask_path);
    end
    
    num_clusters=system_numeric_output(['fslstats ',cluster_mask_path,' -p 100']);
    valid_cluster_ind = 1;
    if isempty (dir([sub_path,'/cluster_0*']))
        for cluster_i = 1:num_clusters
            cluster_mask_i = sprintf('%s%03i.nii.gz',cluster_mask_path(1:end-11),valid_cluster_ind);
            % Binary map of each cluster
            system(sprintf('fslmaths %s -thr %i -uthr %i -bin %s',cluster_mask_path,cluster_i,cluster_i,cluster_mask_i));
            cluster_size_in_ROI=system_numeric_output(sprintf('fslstats %s -k %s -V',merged_anat_mask,cluster_mask_i));
            cluster_size=system_numeric_output(sprintf('fslstats %s -V',cluster_mask_i));
            if cluster_size_in_ROI/cluster_size < min_prop_2b_included
                delete(cluster_mask_i)
            else
                if valid_cluster_ind == 2
                    system (sprintf('fslmaths %s -mul %i -add %s %s',cluster_mask_i,valid_cluster_ind,[cluster_mask_i(1:end-8),'1'],cluster_valid_mask_path));
                elseif valid_cluster_ind > 2
                    system (sprintf('fslmaths %s -mul %i -add %s %s',cluster_mask_i,valid_cluster_ind,cluster_valid_mask_path,cluster_valid_mask_path));
                end
                valid_cluster_ind = valid_cluster_ind + 1;
            end
        end
        waitbar(subject/length(subjects),h,sprintf('Creating masks for subject %i out of %i',subject,length(subjects)))
    end
end

for subject = subjects
    sub_name =  sprintf('sub-%03i',subject);
    sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
    valid_clusters=dir([sub_path,'cluster_0*']);
    num_clusters = length(valid_clusters);
    
    progress = 0;
    cluster_means{subject} = nan(num_clusters,num_ROIs);
    cluster_means_norm{subject} = nan(num_clusters,num_ROIs);
    
    for cluster_i = 1:num_clusters
        cluster_mask_i = [valid_clusters(cluster_i).folder,'/',valid_clusters(cluster_i).name];
        
        for ROI_i = 1:num_ROIs
            % Mean probability each cluster is of ROI: <ROI> -k <cluster mask> -M
            cluster_mean=system_numeric_output(sprintf('fslstats %s/%s -k %s -M',ROI(ROI_i).folder,ROI(ROI_i).name,cluster_mask_i));
            cluster_size_in_ROI=system_numeric_output(sprintf('fslstats %s/%s -k %s -V',ROI(ROI_i).folder,ROI(ROI_i).name,cluster_mask_i));
            cluster_size=system_numeric_output(sprintf('fslstats %s -V',cluster_mask_i));
            
            % mean loading of cluster in ROI
            cluster_means{subject}(cluster_i,ROI_i)=cluster_mean;
            % corrected by prop of cluster outside the ROI
            cluster_means_norm{subject}(cluster_i,ROI_i)=cluster_mean*(cluster_size_in_ROI/cluster_size);
            
            progress = progress +1;
            waitbar(progress/(num_clusters*num_ROIs),h,sprintf('Analyzing subject %i out of %i: Cluster %i out of %i.',subject,length(subjects),cluster_i,num_clusters))
        end
    end
end
save('test.mat')
ROI_names=strrep({ROI.name},'probability_mask_','');
ROI_names=strrep(ROI_names,'.nii.gz','');
cluster_table = mat2dataset(nan(length(subjects),num_ROIs),'VarNames',ROI_names);
cluster_table_weights = mat2dataset(nan(length(subjects),num_ROIs),'VarNames',ROI_names);

for subject = subjects
    waitbar(subject/length(subjects),h,sprintf('Searching best match for subject %i out of %i',subject,length(subjects)))
    [best_combination1,best_combination_score1] = find_best_match (cluster_means{subject},0.05);
    [best_combination2,best_combination_score2] = find_best_match (cluster_means_norm{subject});
    
    models_agree = best_combination1 == best_combination2;
    cluster_table(subject,models_agree)=mat2dataset(best_combination1(models_agree));
    cluster_table_weights(subject,models_agree)=mat2dataset(best_combination_score1(models_agree));
end

cluster_table = dataset2table(cluster_table);
cluster_table_weights =  dataset2table(cluster_table_weights);

cluster_mat = table2array(cluster_table);
[undecided_ROIs_sub,undecided_ROIs_ROI] = ind2sub(size(cluster_mat),find(isnan(cluster_mat)));

for ind = 1:length(undecided_ROIs_sub)
    ROI_name = ROI_names{undecided_ROIs_ROI(ind)};
    clusters_path = sprintf('%s/Functional_ROI/sub-%03i/cluster_valid_mask.nii.gz',pwd,undecided_ROIs_sub(ind));
    %clusters_path = sprintf('%s/Functional_ROI/sub-%03i/cluster_0*.nii.gz',pwd,undecided_ROIs_sub(ind));
    
    world_location = sprintf('%i %i %i',ROI_center_mass{undecided_ROIs_ROI(ind)});
    visualization_str = ['fsleyes -wl ',world_location,' /share/apps/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz ',clusters_path,' -cm hsv -n find_',ROI_name,' &'];
    visualize_fsleyes = questdlg (['Plesae help validate the location of the ROI: ',ROI_name,'. Do you want to visualize with system or copy to clipboard?'], ['Validate',ROI_name], 'system', 'clipboard', 'system');
    
    if strcmp(visualize_fsleyes,'system')
        system(visualization_str);
    else
        clipboard('copy',visualization_str);
    end
    
    [best_combination1,best_combination_score1] = find_best_match (cluster_means{undecided_ROIs_sub(ind)},0.05);
    % suggestions = best_combination1(undecided_ROIs_ROI(ind));
    num_options = size(cluster_means{undecided_ROIs_sub(ind)},1);
    ROI_options = split(sprintf('Cluster_%03i ',1:num_options));
    ROI_options(end) = {'None'};
    
    for suggestion_ind = 1:length(best_combination1)
        suggestion = best_combination1(suggestion_ind);
        add_star='; ';
        if suggestion_ind == undecided_ROIs_ROI(ind)
            add_star = '**; ';
        end
        
        
        if suggestion>0
            ROI_options(suggestion) = {[ROI_options{suggestion},' - suggested ',ROI_names{suggestion_ind},add_star]};
        else
            ROI_options(end) = {[ROI_options{end},' - suggested ',ROI_names{suggestion_ind},add_star]};
        end
    end
    ROI_selected = listdlg('PromptString',['Select the best candidate for: ',ROI_name],...
        'SelectionMode','single','ListString',ROI_options,'ListSize',[300,300]);
    if ROI_selected == length(ROI_options)
        ROI_selected = 0;
    end
    cluster_table(undecided_ROIs_sub(ind),undecided_ROIs_ROI(ind))= array2table(ROI_selected);
end
close(h)
save('Functional2ROI_results.mat');
writetable(cluster_table,'cluster_table.txt','Delimiter','\t')

cluster_mat = table2array(cluster_table);
for subject = subjects
        sub_name =  sprintf('sub-%03i',subject);
    sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
    for ROI_i = 1:num_ROIs
        if cluster_mat(subject,ROI_i) > 0
            copyfile([sub_path,sprintf('cluster_%03i.nii.gz',cluster_mat(subject,ROI_i))],[sub_path,sprintf('ROI_%02i_%s.nii.gz',ROI_i,ROI_names{ROI_i})]);
        end
    end   
end 

