% This code uses probability ROI masks based on anatomical and results from
% the functional localizer to create a functional ROI mask.

clear;
close all;
clc;

% create environment in order to be able to run FSL from Matlab
setenv('FSLDIR','/share/apps/fsl/'); %the FSL folder
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %the output type
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% Define the following variables

ses_num =1 ;
ROI_table = readtable('selected_ROI_table_2018_08_15.txt','delimiter','\t');
p_thresh = 0.00001; % threshold to detect outliers
size_thresh = 12; % threshold to minimal cluster size
% if you want to exclude based on this threshold, re run script 04, with the new table created by this script
number_cores = 25;

if ses_num ==1
    subjects=[2,4:14,16:17,19:25,27:41,43:49];
elseif ses_num ==2
    subjects=[2,4:5,8,10:12,14,17,20:23,27,29:31,33:36,38:40,44];
end

if isempty(gcp('nocreate'))
parpool(number_cores)
end

ROI_mat = table2array(ROI_table);
num_ROIs = (size(ROI_table,2)-1)/2;
ROI_names = ROI_table.Properties.VariableNames(2:1+num_ROIs);
ROI_center_mass_mat = nan(numel(subjects),num_ROIs,3);
ROI_size_mat = nan(numel(subjects),num_ROIs);

parfor_progress(numel(subjects));
parfor subject_i = 1:numel(subjects)
    subject=subjects(subject_i);
    sub_name =  sprintf('sub-%03i',subject);
    sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
    for ROI_i = 1:num_ROIs
        cluster_i = ROI_mat(subject_i,1+ROI_i);
        if isnan(cluster_i) % in case the ROI was not found - skip
            continue
        end
        cluster_mask_output = sprintf('%sROI_%02i_%s.nii.gz',sub_path,ROI_i,ROI_names{ROI_i});
        [~,ROI_center_mass_tmp]=system_numeric_output(sprintf('fslstats %s -c',cluster_mask_output));
        [~,ROI_size_tmp]=system_numeric_output(sprintf('fslstats %s -h 2',cluster_mask_output));
        ROI_center_mass_mat(subject_i,ROI_i,:)=ROI_center_mass_tmp(1:3);
        ROI_size_mat(subject_i,ROI_i) = ROI_size_tmp(2);
    end
parfor_progress();
end
parfor_progress(0);

%% Plot the results in 3d graph
for ROI_i = 1:num_ROIs
    dat = [ROI_center_mass_mat(:,ROI_i,1),ROI_center_mass_mat(:,ROI_i,2),ROI_center_mass_mat(:,ROI_i,3)];
    mu = nanmean(dat);
    sigma2 = nanvar(dat);
    p = multivariateGaussian(dat,mu,sigma2);
    figure('units','normalized','outerposition',[0.25,0.1,0.5,0.8],'Name',sprintf('\nROI %02i - %s',ROI_i,ROI_names{ROI_i}))
    scatter3(dat(:,1),dat(:,2),dat(:,3),[],p,'filled')
    outlier = p<p_thresh;
    ColorData=zeros(length(p),3);
    ColorData(:,2)=p/max(p);
    ColorData(:,1)=1-p/max(p);
    textscatter3(dat,string(1:length(p)),'ColorData',ColorData,'TextDensityPercentage',100)
    hold on
    textscatter3(dat,string(1:length(p)),'ColorData',ColorData,'TextDensityPercentage',0)
    scatter3(dat(outlier,1),dat(outlier,2),dat(outlier,3),200,'k')
    title(sprintf('\nROI %02i - %s',ROI_i,ROI_names{ROI_i}),'interpreter','none')
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    hold off
    fprintf('\nROI %02i - %s Outliers:\n',ROI_i,ROI_names{ROI_i})
    fprintf('%i \n',find(outlier))
    fprintf('\n')
end

%% Plot the results in 2d graph
for ROI_i = 1:num_ROIs
    dat = ROI_size_mat(:,ROI_i);
    mu = nanmean(dat);
    sigma2 = nanvar(dat);
    figure('units','normalized','outerposition',[0.25,0.1,0.5,0.8],'Name',sprintf('\nROI %02i - %s',ROI_i,ROI_names{ROI_i}))
    scatter(1:length(dat),dat,'filled')
    outlier_low = dat<size_thresh;
    outlier_high = zscore(dat)>3;
    [sorted,ind]=sort(dat);
    p = multivariateGaussian(sorted,mu,sigma2);
    ColorData=zeros(length(p),3);
    ColorData(:,2)=p/max(p);
    ColorData(:,1)=1-p/max(p);
    textscatter(1:length(p),sorted,string(ind),'ColorData',ColorData,'TextDensityPercentage',100)

    hold on
       hline = refline(0,size_thresh);
       hline.Color='r';
       hline.LineStyle='--';
    title(sprintf('\nROI %02i - %s',ROI_i,ROI_names{ROI_i}),'interpreter','none')
    xlabel('Rank')
    ylabel('Cluster Size')
    hold off
    fprintf('\nROI %02i - %s Outliers (low):\n',ROI_i,ROI_names{ROI_i})
    fprintf('%i \n',find(outlier_low))
    fprintf('\n')
    fprintf('\nROI %02i - %s Outliers (high):\n',ROI_i,ROI_names{ROI_i})
    fprintf('%i \n',find(outlier_high))
    fprintf('\n')
end

% Generate new ROI table without the excluded clusters
ROIs_2_remove = ROI_size_mat<size_thresh;
ROI_mat2 = ROI_mat(:,1+(1:num_ROIs));
ROI_mat2(ROIs_2_remove)=nan;
ROI_table2 = ROI_table;
ROI_table2(:,1+(1:num_ROIs)) = array2table(ROI_mat2);
date = clock;
writetable(ROI_table2,sprintf('selected_ROI_table_%i_%02i_%02i',date(1),date(2),date(3)),'delimiter','\t')

mean_center_mass = reshape(nanmean(ROI_center_mass_mat),[6,3]);
mean_center_mass = reshape(nanmean(ROI_size_mat),[6,1]);
mean_center_mass = reshape(nanmean(ROI_size_mat>0),[6,1]);
