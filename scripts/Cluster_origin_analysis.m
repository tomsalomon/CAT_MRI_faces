clear;
close all;


% Define these variables
task_num=2;
ses_num=1;
cope_lev_1=21;
cope_lev_2=9;
cope_lev_3=3;
visualize_fsleyes=false; % True or False

experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/';
group_analysis_path=[experiment_path,'models/model001/ses-',sprintf('%02.f',ses_num),'/group_analysis/'];
design_matrices_path=[pwd,'/design_matrices/'];
breakdown_output_path=[pwd,'/breakdown_results/'];
zthresh='2.3';

% set FSL environment
setenv('FSLDIR','/share/apps/fsl/bin/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

switch task_num
    case 1
        num_of_copes=27;
        contrast_names_lev1={'HV Go';'HV NoGo';'LV Go';'LV NoGo';'HV Neutral';'LV Neutral';'HV Sanity';'LV Sanity';'HV Go - Mod';'HV NoGo - Mod';'LV Go - Mod';'LV NoGo - Mod';'All - Mod by value';'All HV';'All LV';'HV minus LV';'All Go minus NoGo';'HV Go minus NoGo';'LV Go minus NoGo';'All Go minus NoGo - Mod';'HV Go minus NoGo - Mod';'LV Go minus NoGo - Mod';'All Go';'All Go - Mod';'All NoGo';'All NoGo - Mod';'All NoGo - with Neutral and Sanity'};
        contrast_names_lev2={'after > before';'before > after';'before';'after';'mean'};
    case 2
        num_of_copes=25;
        contrast_names_lev1={'HV Go';'HV Go - by choice';'HV Go - by value';'HV Go - by GSD';'LV Go';'LV Go - by choice';'LV Go - by value';'LV Go - by GSD';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by value';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by value';'Go - missed';'NoGo - erroneous response';'NoGo - Sanity and fillers';'All Go - by RT';'HV Go > NoGo';'LV Go > NoGo';'All Go > NoGo';'All Go';'All NoGo';'All Go - by choice';'All NoGo - by choice';};
        contrast_names_lev2={'scan1';'scan2';'scan3';'scan4';'scan5';'scan6';'scan7';'scan8';'last > first';'linear trend'};
    case 3
        num_of_copes=26;
        contrast_names_lev1={'HV Go';'HV Go - by choice';'HV Go - by WTP diff';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by WTP diff';'HV - by RT';'LV Go';'LV Go - by choice';'LV Go - by WTP diff';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by WTP diff';'LV - by RT';'Sanity';'Missed trials';'HV chose Go > chose NoGo';'HV - chose Go > Chose NoGo - mod by choice';'LV - chose Go > Chose NoGo';'LV - chose Go >chose NoGo - mod by choice';'all - chose go > chose NoGo';'All - chose Go > Chose NoGo - mod by choice';'All Go';'All NoGo';'All Go modulated';'All NoGo Modulated'};
        contrast_names_lev2={'mean'};
    case 4
        num_of_copes=[];
        contrast_names_lev1={ };
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

breakdown_output_path=[breakdown_output_path,task_name,sprintf('/cope_%i_%i_%i_%s/',cope_lev_1,cope_lev_2,cope_lev_3,zthresh_str)];
thresh_zstat=sprintf('thresh_zstat_cope_%i_%i_%i.nii.gz',cope_lev_1,cope_lev_2,cope_lev_3);
cluster_mask_zstat=sprintf('cluster_mask_zstat_cope_%i_%i_%i.nii.gz',cope_lev_1,cope_lev_2,cope_lev_3);
cope_main_path_options=dir([group_analysis_path,'group_',task_name,'*',zthresh_str]);

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
if visualize_fsleyes
    system(['fsleyes /share/apps/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz ',breakdown_output_path,cluster_mask_zstat,' -cm hsv ',breakdown_output_path,thresh_zstat,' -cm red-yellow -dr ',display_range,'&']);
end
disp(['fsleyes /share/apps/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz ',breakdown_output_path,cluster_mask_zstat,' -cm hsv ',breakdown_output_path,thresh_zstat,' -cm red-yellow -dr ',display_range,'&']);
clipboard('copy',['fsleyes /share/apps/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz ',breakdown_output_path,cluster_mask_zstat,' -cm hsv ',breakdown_output_path,thresh_zstat,' -cm red-yellow -dr ',display_range,'&']);

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

