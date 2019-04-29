function [] = SVM_prediction_visualization(model_table_sorted,model_i)
% SVM visualization.
% Can be called as a function given an input of a model table and selected
% model, or as a script

if ~exist('model_table_sorted','var')
    % define these
    % Define these variables
    ses_num=1;
    task_num=2;
    group_analysis_path = [pwd,'/../models/model001'];
    
    task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
    task_name=task_names{task_num};
    ses_name = sprintf('ses-%02i',ses_num);
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
    
    load([ROI_GLM_analysis_path,'/results_SVM_analysis.mat']);
    clear('model_i');
end

if ~exist('model_i','var')
    model_i_options = cell(height(model_table_sorted),1);
    for i = 1:height(model_table_sorted)
        cope_description = sprintf('%i. %s (%i): %s (%i)',...
            i, model_table_sorted.cope_lev1_name{i}, model_table_sorted.cope_lev1{i},...
            model_table_sorted.cope_lev2_name{i}, model_table_sorted.cope_lev2{i});
        cope_description(end+1:70) = ' ';
        model_i_options{i} = sprintf('%s Accuracy: %.2f, p = %.3f',...
              cope_description, model_table_sorted.accuracy{i}, model_table_sorted.p(i));
    end
         [model_i] = listdlg('ListString',model_i_options,'ListSize',[600,600],...
            'SelectionMode','Single','Name','Select Model');
end

model = model_table_sorted.model{model_i};
W = model_table_sorted.W{model_i};
data = model_table_sorted.data_norm{model_i};
% y_pre = (table2array(model.X)/model.KernelParameters.Scale)*model.Beta + model.Bias;
y_pre = model_table_sorted.prediction{model_i};
y_real = table2array(data(:,'prop'));
y_pre_bin_model = predict(model,model.X); % sanity check - model trained on itsel, no CV
y_pre_bin = sign(y_pre(:));
y_real_bin = model.Y(:);
model_name = sprintf('model %i: %s - %s',model_i,model_table_sorted.cope_lev1_name{model_i},model_table_sorted.cope_lev2_name{model_i});
training_accuracy = mean(y_pre_bin_model==y_real_bin);
CV_accuracy = model_table_sorted.accuracy{model_i};
p = model_table_sorted.p(model_i);
classify_lim = median(y_real)-0.001;

TP = y_pre_bin==1 & y_real_bin==1;
TN = y_pre_bin==-1 & y_real_bin==-1;
FP = y_pre_bin==1 & y_real_bin==-1;
FN = y_pre_bin==-1 & y_real_bin==1;

figure('name',model_name)
scatter(y_pre(TP),y_real(TP),'k+','linewidth',2)

hold on
ylim([0,1])
xlabel('model load value');
ylabel('Proportion choosing Go item');
title(sprintf('%s\nTraining Accuracy : %.2f, CV Accuracy: %.2f, p = %.2f',...
    model_name,training_accuracy,CV_accuracy,p))
scatter(y_pre(TN),y_real(TN),'ko','linewidth',2)
scatter(y_pre(FP),y_real(FP),'ro','linewidth',2)
scatter(y_pre(FN),y_real(FN),'r+','linewidth',2)
plot([0,0],ylim,'k--')
plot(xlim,[classify_lim,classify_lim],'k--')
legend({'True Positive','True Negative','False Positive','Flase Negative'},'location','northwest')
end
