%% open script: Define env and variables

clear;
close all;
tic

% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% Define these variables
session=1;
task_num=1;
Subjects=[2,4:14,16:17,19:25,27:41,43:49];
number_cores = 28;

task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
task_name=task_names{task_num};
design_template=['design_group_',task_name,'_randomise_template.fsf'];
ses_name = sprintf('ses-%02i',session);
c=clock;
CurrentDate=sprintf('%i_%02.f_%02.f',c(1),c(2),c(3));
output_path = sprintf(...
    '%s/../models/model001/ses-%02i/group_analysis/group_%s_%s_face_localizer',...
    pwd,session,task_name,CurrentDate);
if isempty(dir(output_path))
    mkdir(output_path);
end
ROI_names = {'ROI_01_FFA_left';'ROI_02_FFA_right';'ROI_03_OFA_left';'ROI_04_OFA_right';'ROI_05_STS_left';'ROI_06_STS_right'};
ROI_names_short = {'FFA left';'FFA right';'OFA left';'OFA right';'STS left';'STS right'};
ROI_names_very_short = {'FFA_L';'FFA_R';'OFA_L';'OFA_R';'STS_L';'STS_R'};

switch task_num
    case 1
        num_of_copes_lev1=27;
        contrast_name={'HV Go';'HV NoGo';'LV Go';'LV NoGo';'HV Neutral';'LV Neutral';'HV Sanity';'LV Sanity';'HV Go - Mod';'HV NoGo - Mod';'LV Go - Mod';'LV NoGo - Mod';'All - Mod by value';'All HV';'All LV';'HV minus LV';'All Go minus NoGo';'HV Go minus NoGo';'LV Go minus NoGo';'All Go minus NoGo - Mod';'HV Go minus NoGo - Mod';'LV Go minus NoGo - Mod';'All Go';'All Go - Mod';'All NoGo';'All NoGo - Mod';'All NoGo - with Neutral and Sanity'};
        weights_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,4,4,4,2,1,1,2,1,1,2,2,2,2,6];
        num_of_copes_lev2 = 5;
        contrast_name_lev2 ={'after > before';'before > after';'before';'after';'mean'};
                 weights_lev2 = [1,1,1,1,2];
    
    case 2
        num_of_copes_lev1=25;
        contrast_name={'HV Go';'HV Go - by choice';'HV Go - by value';'HV Go - by GSD';'LV Go';'LV Go - by choice';'LV Go - by value';'LV Go - by GSD';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by value';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by value';'Go - missed';'NoGo - erroneous response';'NoGo - Sanity and fillers';'All Go - by RT';'HV Go > NoGo';'LV Go > NoGo';'All Go > NoGo';'All Go';'All NoGo';'All Go - by choice';'All NoGo - by choice';};
        weights_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2];
        num_of_copes_lev2 = 13;
        contrast_name_lev2 ={'scan1';'scan2';'scan3';'scan4';'scan5';'scan6';'scan7';'scan8';'last > first';'linear trend'};
         weights_lev2 = [1,1,1,1,1,1,1,1,1,10];
    case 3
        num_of_copes_lev1=26;
        contrast_name={'HV Go';'HV Go - by choice';'HV Go - by WTP diff';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by WTP diff';'HV - by RT';'LV Go';'LV Go - by choice';'LV Go - by WTP diff';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by WTP diff';'LV - by RT';'Sanity';'Missed trials';'HV chose Go > chose NoGo';'HV - chose Go > Chose NoGo - mod by choice';'LV - chose Go > Chose NoGo';'LV - chose Go >chose NoGo - mod by choice';'all - chose go > chose NoGo';'All - chose Go > Chose NoGo - mod by choice';'All Go';'All NoGo';'All Go modulated';'All NoGo Modulated'};
        weights_lev1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2];
        num_of_copes_lev2 = 1;
        contrast_name_lev2 ={'mean'};
        weights_lev2 = 1;
    case 4
        num_of_copes_lev1=[];
        contrast_name={ };
end

% initiate parallel computing
parpool(number_cores)

%% Multiply functional mask by BOLD data

num_of_iterations = num_of_copes_lev1*num_of_copes_lev2*length(Subjects)*length(ROI_names);
parfor_progress(num_of_iterations);
parfor cope = 1:num_of_copes_lev1
    for cope_lev2 = 1:num_of_copes_lev2
        cope_output_path = sprintf('%s/cope%i/cope%i',output_path,cope,cope_lev2);
        mkdir(cope_output_path)
        for sub = Subjects
            sub_name = sprintf('sub-%03i',sub);
            sub_2_lev_cope = sprintf('%s/../%s/%s/model/model001/*%s.gfeat/cope%i.feat/stats/cope%i.nii.gz',...
                pwd,sub_name,ses_name,task_name,cope,cope_lev2);
            
            for ROI_ind = 1:length(ROI_names)
                parfor_progress;
                %waitbar(progress/100,h,sprintf('Creating masks for cope %i out of %i\n%.2f%% done',cope,num_of_copes, progress))
                ROI_name = ROI_names{ROI_ind};
                ROI_mask_path = sprintf('%s/face_localizer/Functional_ROI/%s/%s.nii.gz',pwd,sub_name,ROI_name);
                if ~isempty(dir(ROI_mask_path))
                    output_file = sprintf('%s/%s_%s.nii.gz',cope_output_path,sub_name,ROI_name);
                    system(['fslmaths ',ROI_mask_path,' -mul ',sub_2_lev_cope,' ',output_file]);
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
        cope_output_path = sprintf('%s/cope%i/cope%i',output_path,cope,cope_lev2);
        output_files = dir([cope_output_path,'/sub*.nii.gz']);
        tmp1 = cell(length(output_files),1);
        
        parfor file_ind = 1:length(output_files)
            file_path = [output_files(file_ind).folder,'/', output_files(file_ind).name] ;
            nifti_data_raw = niftiread(file_path);
            nifti_data_raw = nifti_data_raw(:);
            nifti_data_non_zero = nifti_data_raw(nifti_data_raw~=0);
            % first cell - file name, second cell - non-zero data
            tmp1{file_ind} = {output_files(file_ind).name, nifti_data_non_zero};
        end
        results{cope,cope_lev2}=tmp1;
        progress = progress + 1/(num_of_copes_lev2*num_of_copes_lev1);
        waitbar(progress,h);
    end
end
close(h)

%% Merge results into one dataframe

h = waitbar(0,'Organizing data into one dataframe');
progress = 0;
results_mat = zeros(1,5);
for cope = 1:num_of_copes_lev1
    for cope_lev2 = 1:num_of_copes_lev2
        % number of valid clusters with results
        num_clusters = length(results{cope,cope_lev2});
        for cluster = 1:num_clusters
            tmp_name = results{cope,cope_lev2}{cluster}{1};
            tmp_name_components = strsplit(tmp_name,{'sub-','_'});
            
            sub = str2double(tmp_name_components{2});
            ROI_ind = str2double(tmp_name_components{4});
            
            results_tmp = (results{cope,cope_lev2}{cluster}{2}); % BOLD
            results_tmp(:,2) = sub; % sub code
            results_tmp(:,3) = ROI_ind;
            results_tmp(:,4) = cope_lev2;
            results_tmp(:,5) = cope;
            results_mat = [results_mat;results_tmp];
            progress = progress + 1/(num_clusters*num_of_copes_lev2*num_of_copes_lev1);
            waitbar(progress,h);
        end
    end
end
results_mat(1,:)=[];
close(h)

% Save results in a table
results_table = array2table(results_mat,'VariableNames',...
    {'BOLD','sub','ROI','cope_lev2','cope_lev1'});
results_table.sub = nominal(results_table.sub);
results_table.BOLD = double(results_table.BOLD);
results_table.cope_lev1_str = contrast_name(results_table.cope_lev1); % add cope titles


%% Calculate statistical model

models_dim = [num_of_copes_lev1,num_of_copes_lev2,length(ROI_names)];
num_models = models_dim(1)*models_dim(2)*models_dim(3);
models = cell(num_models,1);
[model_p,means,SEMs] = deal(nan(num_models,1));

h = waitbar(0,'Computing stats');
for model_ind = 1:num_models
    [cope_1,cope_2,ROI_ind] = ind2sub(models_dim,model_ind);
    selection = (results_table.cope_lev1 == cope_1) & (results_table.cope_lev2 == cope_2) & (results_table.ROI == ROI_ind);
    mean_by_sub = grpstats(results_table(selection,:),'sub','mean','DataVars','BOLD');
    % mixed model linear regression | one sample ttest linear regression
    tmp_model = fitlme(results_table(selection,:),'BOLD ~ 1 + (1|sub)');
    % tmp_model = fitlme(mean_by_sub,'mean_BOLD ~ 1 ');
    
    models{model_ind} = tmp_model;
    model_p(model_ind) = tmp_model.Coefficients.pValue;
    means(model_ind)=mean(mean_by_sub.mean_BOLD);
    SEMs(model_ind) = std(mean_by_sub.mean_BOLD)/sqrt(length(mean_by_sub.mean_BOLD)); % sd / sqrt(n)
    waitbar(model_ind/num_models,h)
end
close(h)

% save results into a table
[cope_1,cope_2,ROI_ind] = ind2sub(models_dim,1:num_models);
stats_array = [cope_1',cope_2',ROI_ind',means,SEMs,model_p];
stats_table = array2table(stats_array,'VariableNames',...
    {'cope_1','cope_2','ROI','BOLD_mean','BOLD_SEM','p'});
stats_table.p_asterisk = strings(size(stats_table.p));
stats_table.p_asterisk(stats_table.p<0.01) = '#';
stats_table.p_asterisk(stats_table.p<0.05) = '*';
stats_table.p_asterisk(stats_table.p<0.01) = '**';
stats_table.p_asterisk(stats_table.p<0.001) = '***';
stats_table.cope_1_str = contrast_name(stats_table.cope_1);
stats_table.ROI_str = ROI_names(stats_table.ROI);
stats_table.model = models;

%% Plot significant results
sig_contrasts = unique(stats_table.cope_1(stats_table.p < 0.05));
for cope_lev2 = 1:num_of_copes_lev2
    fig=figure('Name',sprintf('cope: %i',cope_lev2),'units','normalized','outerposition',[0 0 1 1]);
    p = uipanel('Parent',fig,'BorderType','none');
    p.Title = sprintf('%s - 2nd level cope %i (%s)',task_name,cope_lev2,contrast_name_lev2{cope_lev2});
    p.TitlePosition = 'centertop';
    p.FontSize = 22;
    p.FontWeight = 'bold';
    
    for cope_ind = 1:length(sig_contrasts)
        cope_lev1 = sig_contrasts(cope_ind);
        subplot(3,ceil((1+length(sig_contrasts))/3),cope_ind,'Parent',p)
        
        pos = stats_table.cope_1 == cope_lev1 ;
        % Plot means
        bar(diag(stats_table.BOLD_mean(pos)),'stacked');
        hold on
        % Plot SEM and asterisks
        errorbar(stats_table.BOLD_mean(pos),stats_table.BOLD_SEM(pos),'.k');
        
        y_scale = max(ylim) - min(ylim);
        asterisk_pos = max(...
            [zeros(length(ROI_names),1),...
            stats_table.BOLD_mean(pos)+stats_table.BOLD_SEM(pos)]...
            ,[],2) + y_scale/20;
        text(1:length(ROI_names),asterisk_pos,stats_table.p_asterisk(pos),'HorizontalAlignment','center')
        ylim(ylim + [0, y_scale/10]) % set y axis a little higher than usual to make room for legend
        title(sprintf('Cope %i:\n%s',cope_lev1,contrast_name{cope_lev1}))
        set(gca,'XTickLabel',ROI_names_short,'XTickLabelRotation', 45,'FontSize',6)
        pause(0.01)
    end
    legend_plot=subplot(3,ceil((1+length(sig_contrasts))/3),1+cope_ind,'Parent',p);
    bar(0*diag(stats_table.BOLD_mean(pos)),'stacked');
    ylim([1,2]);
    pause(0.01)
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    title('legend');
    leg = legend(ROI_names_short,'Interpreter', 'none','location','none','position',legend_plot.Position);
    set(leg,'Box','off')
    % Save plot to output directory
    %print(sprintf('%s/Results_lev2_cope%i.pdf',output_path,cope_lev2),'-dpdf','-bestfit');
saveas(fig,sprintf('%s/Results_lev2_cope%i.jpg',output_path,cope_lev2));
end

%% Finish script: Save results and close parallel allocation
% save statistics results
save([output_path,'/results.mat'],'results_table','stats_table');
save([output_path,'/results_workspace.mat']);
% close parallel pool
delete(gcp('nocreate'));
toc
