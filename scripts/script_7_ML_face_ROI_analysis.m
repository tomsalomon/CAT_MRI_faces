%% open script: Define env and variables
clear;
close all;
tic

% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% Define these variables
ses_num=1;
task_num=3;
if ses_num ==1
    Subjects=[2,4:14,16:17,19:25,27:41,43:44,46:49];
elseif ses_num ==2
    Subjects=[2,4:5,8,10:12,14,17,20:23,27,29:31,33:36,38:40,44];
end
number_cores = 40;
group_analysis_path = [pwd,'/../models/model001'];

task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
task_name=task_names{task_num};
ses_name = sprintf('ses-%02i',ses_num);
c=clock;
CurrentDate=sprintf('%i_%02.f_%02.f',c(1),c(2),c(3));
behave_data_path_ses1 = './../behavioral_data/';
if ses_num==1
    behave_data_path = behave_data_path_ses1;
else
    behave_data_path = [behave_data_path_ses1,'ses-02/'];
end

ROI_names = {'ROI_01_FFA_right';'ROI_02_FFA_left';'ROI_03_OFA_right';'ROI_04_OFA_left';'ROI_05_STS_right';'ROI_06_STS_left'};
num_of_ROI=numel(ROI_names);
ROI_names_short = {'FFA right';'FFA left';'OFA right';'OFA left';'STS right';'STS left'};
ROI_names_very_short = {'FFA_R';'FFA_L';'OFA_R';'OFA_L';'STS_R';'STS_L'};
contrast_name_lev3 = {'mean';'mod by probe effect'};
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
        copes_lev2_2skip = 2:7;
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

[is_HV_contrast,is_LV_contrast,is_All_contrast,is_Sanity_contrast,...
    is_Neutral_contrast]=deal(false(size(contrast_name)));

for i=1:length(contrast_name)
    is_HV_contrast(i)=~isempty(regexpi(contrast_name{i},'HV'));
    is_LV_contrast(i)=~isempty(regexpi(contrast_name{i},'LV'));
    is_All_contrast(i)=~isempty(regexpi(contrast_name{i},'All'));
    is_Sanity_contrast(i)=~isempty(regexpi(contrast_name{i},'sanity'));
    is_Neutral_contrast(i)=~isempty(regexpi(contrast_name{i},'Neutral'));
end
is_neither_HV_nor_LV_contrast=is_Sanity_contrast|(is_HV_contrast&is_LV_contrast)|(is_All_contrast&is_LV_contrast)|(is_All_contrast&is_HV_contrast)|is_Neutral_contrast;
is_HV_contrast(is_neither_HV_nor_LV_contrast)=false;
is_LV_contrast(is_neither_HV_nor_LV_contrast)=false;

if sum(is_HV_contrast.*is_LV_contrast.*is_All_contrast)~=0
    warning(['Overlap between contrast. Contrasts were not defined correctly. ',...
        'Please fix this issue before running the group analysis'])
end

% modulation as proportions Go items were chosen: HV, LV, Means
prop_chose_Go=zeros(length(Subjects),3);
for i=1:length(Subjects)
    probe_data=Probe_analysis(Subjects(i),behave_data_path);
    prop_chose_Go(i,:)=[probe_data(7),probe_data(8),mean(probe_data(7:8))];
end
% modulation matrix: rows = sub, cols = cope
probe_mudulation=prop_chose_Go(:,1)*is_HV_contrast'+prop_chose_Go(:,2)*is_LV_contrast'+prop_chose_Go(:,3)*is_All_contrast';
probe_mudulation_demeaned=detrend(probe_mudulation,'constant');
contrast_type = is_HV_contrast + is_LV_contrast*2 + is_All_contrast*3;

% % initiate parallel computing
% if isempty(gcp('nocreate'))
%     parpool(number_cores)
% end

%% Load the data from previous face ROI analysis
ROI_GLM_analysis_path_options = dir (sprintf('%s/%s/group_analysis/*%s*face_localizer',group_analysis_path,ses_name,task_name));
if isempty(ROI_GLM_analysis_path_options)
    error ('No GLM analysis folder found. you have to run the GLM script first');
elseif length(ROI_GLM_analysis_path_options)==1
    selection=1;
elseif length(ROI_GLM_analysis_path_options)>1
    [selection] = listdlg('ListString',{ROI_GLM_analysis_path_options.name},'ListSize',[600,600],...
        'SelectionMode','Single','Name','Select GLM analysis path');
end
ROI_GLM_analysis_path=[ROI_GLM_analysis_path_options(selection).folder,'/',ROI_GLM_analysis_path_options(selection).name];
load([ROI_GLM_analysis_path,'/results.mat'])
%% Calculate statistical model

model_table_headers = {'cope_lev2','cope_lev1','cope_lev2_name','cope_lev1_name','accuracy','model','data'};
model_table = cell2table(cell(num_of_copes_lev2*num_of_copes_lev1,length(model_table_headers)),'variableNames',model_table_headers);
data_table_var_names = [ROI_names',strcat(ROI_names','_n'),strcat(ROI_names','_sd'),{'sub','prop','prop_bin'}];
data_empty_mat = nan(numel(Subjects),numel(data_table_var_names));
models_dim = [num_of_copes_lev2,num_of_copes_lev1];
num_models = models_dim(1)*models_dim(2);
% predictorNames = [ROI_names];
predictorNames = {data_table_var_names{1:end-3}};
predictedNames = {'prop_bin'};

h = waitbar(0,'Computing models');
for model_ind = 1:num_models
    [cope_lev2,cope_lev1] = ind2sub(models_dim,model_ind);
    
    model_table.cope_lev1(model_ind) = {cope_lev1};
    model_table.cope_lev2(model_ind) = {cope_lev2};
    model_table.cope_lev1_name(model_ind) = contrast_name(cope_lev1);
    model_table.cope_lev2_name(model_ind) = contrast_name_lev2(cope_lev2);
    if contrast_type(cope_lev1) == 0
        continue
    end
    if ismember(cope_lev2,copes_lev2_2skip)
        continue
    end
    data_table = array2table(data_empty_mat,'variableNames',data_table_var_names);
    data_table.sub = Subjects';
    for sub_i = 1:numel(Subjects)
        subject=Subjects(sub_i);
        data_table.prop(data_table.sub == (subject)) = prop_chose_Go(sub_i,contrast_type(cope_lev1));
        for ROI_i = 1:num_of_ROI
            clsuter_ind = find((results_table.sub == nominal(subject)) & (results_table.ROI == ROI_i) & (results_table.cope_lev1 == cope_lev1) & (results_table.cope_lev2 == cope_lev2));
            if ~isempty(clsuter_ind)
                data_table(sub_i,ROI_names{ROI_i})={results_table.BOLD(clsuter_ind)};
            end
        end
    end
    data_table.prop_bin = sign(data_table.prop-median(data_table.prop)+1e-5); %add small number to avoid 0 for actual median
    [trainedClassifier, validationAccuracy] = SVMClassifierPermutationTest(data_table,predictorNames,predictedNames);
    model_table.data(model_ind) = {data_table};
    model_table.model(model_ind) = {trainedClassifier};
    model_table.accuracy(model_ind) = {validationAccuracy};
    waitbar(model_ind/num_models,h);
end
% remove untested models
model_table(cellfun(@isempty,model_table.accuracy),:)=[];
close(h)

[~,ind] = sort(cell2mat(model_table.accuracy),'descend');
model_table_sorted = model_table(ind,:);

%% Permutation testings
num_interesting_models = sum(cell2mat(model_table_sorted.accuracy) >= 0.64);
model_table_sorted.p(:) = nan;
for model_i = 1:num_interesting_models
    data = model_table_sorted.data{model_i};
    test_title = sprintf('model %i out of %i',model_i,num_interesting_models);
    [~,~,p,data_norm,W] = SVMClassifierPermutationTest(data,predictorNames,predictedNames,500,test_title);
    model_table_sorted.p(model_i)=p;
    model_table_sorted.data_norm(model_i)={data_norm};
    model_table_sorted.W(model_i)={W};
    SVM_prediction_visualization(model_table_sorted,model_i);
end

save([ROI_GLM_analysis_path,'/results_SVM_analysis.mat'])

