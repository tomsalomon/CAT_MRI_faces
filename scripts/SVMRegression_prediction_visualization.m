function [] = SVMRegression_prediction_visualization(model_table_sorted,model_i)
% SVM visualization

model = model_table_sorted.model{model_i};
W = model_table_sorted.W{model_i};
data = model_table_sorted.data_norm{model_i};
y_pre = model_table_sorted.prediction{model_i};
y_real = table2array(data(:,'prop'));
model_name = sprintf('model %i: %s - %s',model_i,model_table_sorted.cope_lev1_name{model_i},model_table_sorted.cope_lev2_name{model_i});
training_accuracy = corr(y_pre,y_real);
CV_accuracy = model_table_sorted.accuracy{model_i};
p = model_table_sorted.p(model_i);

figure('name',model_name)
scatter(y_pre,y_real,'k+','linewidth',2)
hold on
ylim([0,1])
xlabel('model prediction');
ylabel('Proportion choosing Go item');
title(sprintf('%s\nTraining Accuracy : %.2f, CV Accuracy: %.2f, p = %.2f',...
    model_name,training_accuracy,CV_accuracy,p))
plot([0,0],ylim,'k--')
end
