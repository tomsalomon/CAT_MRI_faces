clear;
close all;


% Define these variables
task_num=2;
ses_num=1;
model = 3;
cope_lev_1=1;
cope_lev_2=2;
cope_lev_3=2;
visualize_fsleyes=false; % True or False
zthresh='2.3'; % '2.3' or '3.1' or 'SVC_0*'

min_n = 5; % show only ROI with at least this number of voxels
experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/';
%group_analysis_path=[experiment_path,'models/model',sprintf('%03.f',model_num),'/ses-',sprintf('%02.f',ses_num),'/group_analysis/'];
group_analysis_path = sprintf('%s/models/model%03i/ses-%02i/group_analysis/',experiment_path,model,ses_num);
tmp_path = [pwd,'/tmp']; % where tmporary files will be saved
HO_atlas = [pwd,'/HOA.nii.gz'];
HO_atlas_labs = readtable([pwd,'/HOA_labs.txt']);
HO_atlas_data = niftiread(HO_atlas);

% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

switch task_num
    case 1
        num_of_copes_lev1=27;
        contrast_names_lev1={'HV Go';'HV NoGo';'LV Go';'LV NoGo';'HV Neutral';'LV Neutral';'HV Sanity';'LV Sanity';'HV Go - Mod';'HV NoGo - Mod';'LV Go - Mod';'LV NoGo - Mod';'All - Mod by value';'All HV';'All LV';'HV minus LV';'All Go minus NoGo';'HV Go minus NoGo';'LV Go minus NoGo';'All Go minus NoGo - Mod';'HV Go minus NoGo - Mod';'LV Go minus NoGo - Mod';'All Go';'All Go - Mod';'All NoGo';'All NoGo - Mod';'All NoGo - with Neutral and Sanity'};
        contrast_fix_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,4,4,4,2,1,1,2,1,1,2,2,2,2,6];
        num_of_copes_lev2 = 5;
        contrast_names_lev2 ={'after > before';'before > after';'before';'after';'mean'};
        contrast_fix_lev2 = [1,1,1,1,2];
        baseline_2_max = 0.4075; % hight with double gamma - 2s stim
        
    case 2
        num_of_copes_lev1=25;
        contrast_names_lev1={'HV Go';'HV Go - by choice';'HV Go - by value';'HV Go - by GSD';'LV Go';'LV Go - by choice';'LV Go - by value';'LV Go - by GSD';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by value';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by value';'Go - missed';'NoGo - erroneous response';'NoGo - Sanity and fillers';'All Go - by RT';'HV Go > NoGo';'LV Go > NoGo';'All Go > NoGo';'All Go';'All NoGo';'All Go - by choice';'All NoGo - by choice';};
        contrast_fix_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2];
        num_of_copes_lev2 = 10;
        contrast_names_lev2 ={'scan1';'scan2';'scan3';'scan4';'scan5';'scan6';'scan7';'scan8';'last > first';'linear trend'};
        contrast_fix_lev2 = [1,1,1,1,1,1,1,1,1,10];
        baseline_2_max = 0.2088; % hight with double gamma - 1s stim
        
    case 3
        num_of_copes_lev1=26;
        contrast_names_lev1={'HV Go';'HV Go - by choice';'HV Go - by WTP diff';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by WTP diff';'HV - by RT';'LV Go';'LV Go - by choice';'LV Go - by WTP diff';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by WTP diff';'LV - by RT';'Sanity';'Missed trials';'HV chose Go > chose NoGo';'HV - chose Go > Chose NoGo - mod by choice';'LV - chose Go > Chose NoGo';'LV - chose Go >chose NoGo - mod by choice';'All - chose go > chose NoGo';'All - chose Go > Chose NoGo - mod by choice';'All Go';'All NoGo';'All Go modulated';'All NoGo Modulated'};
        contrast_fix_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2];
        num_of_copes_lev2 = 1;
        contrast_names_lev2 ={'mean'};
        contrast_fix_lev2 = 1;
        baseline_2_max = 0.2088; % hight with double gamma - 1s stim
end

contrast_names_lev3={'';' - correlation with CAT effect';' - inverse';' - correlation with CAT effect (inv)'};
task_names={'task-responsetostim';'task-training';'task-probe';'task-localizer';};
task_name=task_names{task_num};
contrast_name_lev1=contrast_names_lev1{cope_lev_1};
contrast_name_lev2=contrast_names_lev2{cope_lev_2};
contrast_name_lev3=contrast_names_lev3{cope_lev_3};
zthresh_str=strrep(num2str(zthresh),'.','_');
contrast_name = sprintf('%s (%s)%s',contrast_name_lev1,contrast_name_lev2,contrast_name_lev3);

cope_main_path_options=dir([group_analysis_path,'group_',task_name,'*',zthresh_str,'*']);
if isempty(cope_main_path_options)
    error('Error: no results directory found. please make sure the paths are correctly defined')
elseif length(cope_main_path_options)==1
    analysis_dir_selection=1;
else
    analysis_dir_selection = listdlg('PromptString','Select an analysis directory:','SelectionMode','single','ListString',{cope_main_path_options.name},'ListSize',[500,400]);
end
origin_dir=[group_analysis_path,cope_main_path_options(analysis_dir_selection).name,sprintf('/cope%i.gfeat/cope%i.feat/',cope_lev_1,cope_lev_2)];
origin_thresh_zstat=[origin_dir,sprintf('thresh_zstat%i.nii.gz',cope_lev_3)];
origin_cluster_mask=[origin_dir,sprintf('cluster_mask_zstat%i.nii.gz',cope_lev_3)];
[~,tmp]=system(['fslstats ',origin_cluster_mask,' -p 100']);
num_of_sig_cluster=str2double(tmp);

std_data_path = sprintf('%s/cluster_zstat%i_std.txt',...
    origin_dir,cope_lev_3);
std_data = readtable(std_data_path);
if num_of_sig_cluster==0
    error('The requested cope has no significant cluster corrected results. Breakdown is irrelevant')
end
HOA_data = niftiread(HO_atlas);
table_headers = {'Contrast','Cluster','Region','Number_of_voxels_in_the_region',...
    'Cluster_size','X','Y','Z','Peak_Z_value','p'};

out_table = [];
for cluster=1:num_of_sig_cluster
    tmp_cluster_mask=sprintf('%s/cluster_mask%i.nii.gz',tmp_path,cluster);
    system(sprintf('fslmaths %s -thr %i -uthr %i -bin %s',...
        origin_cluster_mask,cluster,cluster,tmp_cluster_mask));
    
    cluster_data = niftiread(tmp_cluster_mask);
    cluster_labs = HOA_data(cluster_data==1);
    % remove unlabeled voxels
    cluster_labs(cluster_labs==0)=[];
    delete(tmp_cluster_mask);
    [lab_ind_n,lab_ind]=hist(cluster_labs,unique(cluster_labs));
    if length(unique(cluster_labs)) ==1
    [lab_ind_n,lab_ind]=hist(cluster_labs,1);
    end
    cluster_ROI = HO_atlas_labs.label(ismember(HO_atlas_labs.ind,lab_ind));
    % Sort by number of apprearances
    [lab_ind_n,order] = sort(lab_ind_n,'descend');
    lab_ind = lab_ind(order);
    cluster_ROI = cluster_ROI(order);
    % filter by minimal n
    filter = lab_ind_n >= min_n;
    lab_ind_n_f = lab_ind_n(filter);
    lab_ind_f = lab_ind(filter);
    cluster_ROI_f = cluster_ROI(filter);
    num_of_regions = length(cluster_ROI_f);
    
    std_data_tmp = std_data(std_data.ClusterIndex==cluster,:);
    % write data to table
    out_table_tmp = cell(num_of_regions,length(table_headers));
    out_table_tmp{1,1} = contrast_name;
    out_table_tmp{1,2} = cluster;
    try % cluster which are all cerebellum or WM
    [out_table_tmp{:,3}] = cluster_ROI_f{:};
    lab_ind_n_f_tmp = num2cell(lab_ind_n_f(:));
    [out_table_tmp{:,4}] = lab_ind_n_f_tmp{:};
    catch
        out_table_tmp{:,3} = 'Cerebellum or white matter';
        out_table_tmp{:,4} = 0;
    end
    out_table_tmp{1,5} = std_data_tmp.Voxels;
    out_table_tmp{1,6} = std_data_tmp.Z_MAXX_mm_;
    out_table_tmp{1,7} = std_data_tmp.Z_MAXY_mm_;
    out_table_tmp{1,8} = std_data_tmp.Z_MAXZ_mm_;
    out_table_tmp{1,9} = sprintf('%.3f',std_data_tmp.Z_MAX);
    out_table_tmp{1,10} = std_data_tmp.P;
    out_table_tmp = cell2table(out_table_tmp,'VariableNames',table_headers);
    out_table = [out_table;out_table_tmp];
    contrast_name = [];
end

disp(out_table);


