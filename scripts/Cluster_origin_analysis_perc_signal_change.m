clear;
close all;


% Define these variables
task_num=1;
ses_num=1;
cope_lev_1=17;
cope_lev_2=1;
cope_lev_3=1;
visualize_fsleyes=false; % True or False
zthresh='2.3'; % '2.3' or '3.1' or 'SVC_0*'

experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/';
group_analysis_path=[experiment_path,'models/model001/ses-',sprintf('%02.f',ses_num),'/group_analysis/'];
design_matrices_path=[pwd,'/design_matrices/'];
breakdown_output_path=[pwd,'/breakdown_results/'];

if ses_num ==1
    Subjects=[2,4:14,16:17,19:25,27:41,43:49];
elseif ses_num ==2
    Subjects=[2,4:5,8,10:12,14,17,20:23,27,29:31,33:36,38:40,44];
end
behave_data_path_ses1 = './../behavioral_data/';
if ses_num==1
    behave_data_path = behave_data_path_ses1;
else
    behave_data_path = [behave_data_path_ses1,'ses-02/'];
end
ses_name = sprintf('ses-%02i',ses_num);

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

contrast_names_lev3={'group mean';'cope - by probe effect';'group mean - inverse';'cope - by probe effect inverse'};
task_names={'task-responsetostim';'task-training';'task-probe';'task-localizer';};
task_name=task_names{task_num};
contrast_name_lev1=contrast_names_lev1{cope_lev_1};
contrast_name_lev2=contrast_names_lev2{cope_lev_2};
contrast_name_lev3=contrast_names_lev3{cope_lev_3};
zthresh_str=strrep(num2str(zthresh),'.','_');

level_1_design_mat=table2array(readtable(sprintf('%stask-0%i_lev-01.txt',design_matrices_path,task_num),'delimiter','\t'));
level_2_design_mat=table2array(readtable(sprintf('%stask-0%i_lev-02.txt',design_matrices_path,task_num),'delimiter','\t'));

level1_components=find(level_1_design_mat(cope_lev_1,:));
level2_components_tmp=find(level_2_design_mat(cope_lev_2,:));

ind=0;
level2_components=zeros(1,length(level2_components_tmp));
level2_weigths=level2_components;

try
    for comp=level2_components_tmp
        ind=ind+1;
        level2_weigths(ind)=level_2_design_mat(cope_lev_2,level2_components_tmp(ind));
        comp_template=zeros(1,length(level_2_design_mat(1,:)));
        comp_template(comp)=1;
        level2_components(ind)=find(ismember(level_2_design_mat,comp_template,'rows'));
    end
catch
    level2_components=1;
end
% add the contrast itself - relevent to contrast of more than 1 regressor
if ~ismember(cope_lev_1,level1_components)
    level1_components=[cope_lev_1,level1_components];
end

breakdown_output_path=[breakdown_output_path,task_name,sprintf('/cope_%i_%i_%i_%s/',cope_lev_1,cope_lev_2,cope_lev_3,ses_name)];
thresh_zstat=sprintf('thresh_zstat_cope_%i_%i_%i.nii.gz',cope_lev_1,cope_lev_2,cope_lev_3);
cluster_mask_zstat=sprintf('cluster_mask_zstat_cope_%i_%i_%i.nii.gz',cope_lev_1,cope_lev_2,cope_lev_3);
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

if num_of_sig_cluster==0
    error('The requested cope has no significant cluster corrected results. Breakdown is irrelevant')
end

% if isempty(dir([breakdown_output_path,'masked_zstat_cluster_01*']))
mkdir(breakdown_output_path);
copyfile(origin_thresh_zstat,[breakdown_output_path,thresh_zstat])
copyfile(origin_cluster_mask,[breakdown_output_path,cluster_mask_zstat])


analysis_progress=0;
analysis_duration=num_of_sig_cluster*length(level2_components)*length(level1_components);
h = waitbar(analysis_progress,'Analyzing: copying data...');

for cluster=1:num_of_sig_cluster
    cluster_mask=sprintf('cluster_mask%i.nii.gz',cluster);
    system(sprintf('fslmaths %s -thr %i -uthr %i -bin %s%s',origin_cluster_mask,cluster,cluster,breakdown_output_path,cluster_mask));
    
    for level2_component=level2_components % 2nd level breakdown
        for level1_component=level1_components % 1st level breakdown
            % ONCE DONE RUNNING TRAINING CHANGE THIS TO
            % cope_main_path(end) + maybe a warning..
            origin_component_zstat=[group_analysis_path,cope_main_path_options(analysis_dir_selection).name,sprintf('/cope%i.gfeat/cope%i.feat/stats/zstat%i.nii.gz',level1_component,level2_component,cope_lev_3)];
            component_cluster_mask_zstat=sprintf('masked_zstat_cluster_%02.f_cope_%i_%i_%i.nii.gz',cluster,level1_component,level2_component,cope_lev_3);
            
            % change outputname!!!
            system(['fslmaths ',origin_component_zstat,' -mul ',breakdown_output_path,cluster_mask,' ',breakdown_output_path,component_cluster_mask_zstat]);
            analysis_progress=analysis_progress+1/analysis_duration;
            waitbar(analysis_progress,h);
        end
    end
end
close(h)
% end

display_range='2.3 4.3';
visualize_cmd = ['fsleyes /share/apps/fsl/data/standard/MNI152_T1_0.5mm.nii.gz -in linear -dr 40 220 ',breakdown_output_path,cluster_mask_zstat,' -cm hsv ',breakdown_output_path,thresh_zstat,' -cm red-yellow -dr ',display_range,' &'];
if visualize_fsleyes
    system(visualize_cmd);
end
clipboard('copy',visualize_cmd);
pause(0.1);

analysis_progress=0;
analysis_duration=num_of_sig_cluster*length(level2_components)*length(level1_components);
h = waitbar(analysis_progress,'Analyzing: Calculating mean...');
components_contribution=zeros(analysis_duration,6);
components_names=cell(analysis_duration,1);
for cluster=1:num_of_sig_cluster
    for level2_component=level2_components % 2nd level breakdown
        level2_ind=find(level2_components==level2_component);
        for level1_component=level1_components % 1st level breakdown
            analysis_progress=analysis_progress+1;
            if find(level1_components==level1_component)==1 % the first component is the cope itself
                weight=level2_weigths(level2_ind);
            else
                % weight=level_1_design_mat(cope_lev_1,level1_component)*level_2_design_mat(cope_lev_2,level2_ind);
                weight=level_1_design_mat(cope_lev_1,level1_component)*level2_weigths(level2_ind);
                
            end
            components_names{analysis_progress}=[contrast_names_lev1{level1_component},'\newline ',contrast_names_lev2{level2_component},'\newlineweight = ',num2str(weight)];
            %                         components_names{analysis_progress}={contrast_names_lev1{level1_component};contrast_names_lev2{level2_component}};
            
            component_cluster_mask_zstat=sprintf('masked_zstat_cluster_%02.f_cope_%i_%i_%i.nii.gz',cluster,level1_component,level2_component,cope_lev_3);
            [~,tmp]=system(['fslstats ',breakdown_output_path,component_cluster_mask_zstat,' -M']);
            mean_zvalue=str2double(tmp);
            weighted_zvalue=weight*mean_zvalue;
            components_contribution(analysis_progress,:)=[cluster,level2_component,level1_component,weight,mean_zvalue,weighted_zvalue];
            waitbar(analysis_progress/analysis_duration,h)
        end
    end
    
    second_lev_ind=components_contribution(:,3)==cope_lev_1;
    cluster_ind=components_contribution(:,1)==cluster;
    if sum(cluster_ind&second_lev_ind)>1
        figure('Name',['2nd level breakdown - cluster ',num2str(cluster)])
        ylabel('Contribution (cluster mean Zstat * weight)');
        bar(components_contribution(cluster_ind&second_lev_ind,6));
        title({[contrast_name_lev1,' / ',contrast_name_lev2,' / ',contrast_name_lev3,':'],['2nd level breakdown - cluster ',num2str(cluster)]})
        set(gca,'XtickLabel',components_names(cluster_ind&second_lev_ind))
    end
    
    [components_contribution_sorted,order]=sort(components_contribution(cluster_ind&(~second_lev_ind),6));
    if ~isempty(components_contribution_sorted)
        figure('Name',['1st level breakdown - cluster ',num2str(cluster)])
        bar(components_contribution_sorted);
        ylabel('Contribution (cluster mean Zstat * weight)');
        title({[contrast_name_lev1,' / ',contrast_name_lev2,' / ',contrast_name_lev3,':'],['1st level breakdown - cluster ',num2str(cluster)]})
        components_names_first_level=components_names(cluster_ind&(~second_lev_ind));
        set(gca,'XtickLabel',components_names_first_level(order))
    end
    
end
close(h)




% 3rd level modulation
if ismember(cope_lev_3,[2,4])
    
    is_HV_contrast=contains(contrast_name_lev1,'HV');
    is_LV_contrast=contains(contrast_name_lev1,'LV');
    is_All_contrast=contains(contrast_name_lev1,'All');
    is_Sanity_contrast=contains(contrast_name_lev1,'sanity');
    is_Neutral_contrast=contains(contrast_name_lev1,'Neutral');
    
    is_neither=is_Sanity_contrast|(is_HV_contrast&is_LV_contrast)|(is_All_contrast&is_LV_contrast)|(is_All_contrast&is_HV_contrast)|is_Neutral_contrast;
    is_HV_contrast(is_neither)=false;
    is_LV_contrast(is_neither)=false;
    is_All_contrast(is_neither)=false;
    
    % modulation as proportions Go items were chosen: HV, LV, Means
    prop_chose_Go=zeros(length(Subjects),3);
    for i=1:length(Subjects)
        probe_data=Probe_analysis(Subjects(i),behave_data_path);
        prop_chose_Go(i,:)=[probe_data(7),probe_data(8),mean(probe_data(7:8))];
    end
    % modulation
    probe_modulation=prop_chose_Go(:,1)*is_HV_contrast'+prop_chose_Go(:,2)*is_LV_contrast'+prop_chose_Go(:,3)*is_All_contrast';
    probe_modulation_demeaned=detrend(probe_modulation,'constant');
    
    % convert to percent signal change
    scale_factor = (100 * baseline_2_max ^ 2) / (contrast_fix_lev1(cope_lev_1) * contrast_fix_lev2(cope_lev_2));
    percent_signal_change_path = [breakdown_output_path,'percent_signal_change/'];
    mkdir(percent_signal_change_path);
    per_signal_change_mat = nan([length(probe_modulation),num_of_sig_cluster]);
    h = waitbar(0,'Converting to percent signal change');
    for i=1:length(Subjects)
        sub_name = sprintf('sub-%03i',Subjects(i));
        lev_2_path = sprintf('%s/../%s/%s/model/model001/*%s.gfeat/cope%i.feat/',pwd,sub_name,ses_name,task_name,cope_lev_1);
        
        lev_2_cope_img = sprintf('%s/stats/cope%i.nii.gz',lev_2_path,cope_lev_2);
        lev_2_mean_func= ([lev_2_path,'/mean_func.nii.gz']);
        per_signal_change_img = [percent_signal_change_path,sub_name];
        system(['fslmaths ',lev_2_cope_img,' -mul ',num2str(scale_factor),' -div ',lev_2_mean_func,' ',per_signal_change_img]);
        waitbar(i/length(Subjects),h)
    end
    close(h)
    merged_img =[percent_signal_change_path,'merged_img.nii.gz'];
    system(['fslmerge -t ',merged_img,' ',percent_signal_change_path,'/sub*']);
    
    for cluster = 1:num_of_sig_cluster
        cluster_mask=sprintf('%s/cluster_mask%i.nii.gz',breakdown_output_path,cluster);
        [~,tmp_per_signal_change]=system_numeric_output(['fslmeants -i ',merged_img,' -m ',cluster_mask]);
        mean_change_cluster = tmp_per_signal_change(1:end-1)';
        per_signal_change_mat(:,cluster)=mean_change_cluster; % remove the last nan output;
        
        [r,p]=corr(mean_change_cluster,probe_modulation);
        % plot
        figure('name',sprintf('cluster %i: scatter plot',cluster));
        scatter(mean_change_cluster,probe_modulation);
        lsline;
        title(sprintf('%s\n %s / %s \ncluster %i',task_name,contrast_name_lev1,contrast_name_lev2,cluster));
        xlabel('Mean Percent Signal Change');
        ylabel('Probe effect')
        pause(0.01)
    end
    
end
