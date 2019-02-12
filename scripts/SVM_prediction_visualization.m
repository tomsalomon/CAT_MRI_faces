function [] = SVM_prediction_visualization(model_table_sorted,model_i)
% SVM visualization

model = model_table_sorted.model{model_i};
W = model_table_sorted.W{model_i};
data = model_table_sorted.data_norm{model_i};
y_pre = (table2array(model.X)/model.KernelParameters.Scale)*model.Beta + model.Bias;
y_real = table2array(data(:,'prop'));
y_pre_bin = predict(model,model.X);
y_real_bin = model.Y;
model_name = sprintf('model %i: %s - %s',model_i,model_table_sorted.cope_lev1_name{model_i},model_table_sorted.cope_lev2_name{model_i});
training_accuracy = mean(y_pre_bin==y_real_bin);
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
