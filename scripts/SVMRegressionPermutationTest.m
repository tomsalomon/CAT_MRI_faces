function [trainedClassifier, Accuracy,p, data_norm, W] = SVMRegressionPermutationTest(trainingData,predictorNames,predictedNames,num_permutations,test_title)
% This function runs an SVM model on a given data set. Performs
% leave-one-out CV, and if asked, performs permutation test on the data.
%
% Input:
% trainingData - Data table with the features and response (expected to be
% 1 and -1)
% predictorNames - Cell array with the names of the features in the data
% table. E.g : predictorNames = {'ROI_1', 'ROI_2'}
% predictedNames - Cell with the names of the resposne variable in the data
% table. E.g : predictedNames = {'prop_bin'}
% num_permutations (optional) - run a permutation test with
% num_permutations number of iterations.
% test_title (optional) - a header for the waitbar tracking progress when
% the permutation testing option is used. Usefull when you loop through
% several permutation test.
%
% Output:
% trainedClassifier - SVM trained model based on all samples (take note of
% overfitting when using this output.
% Accuracy - proportion of correctly classified samples in a leave-one-out
% CV
% p - Significance of the model, resulting from the permutation test.
% Proportion of permuted models with identical or better accuracy than the
% original model.

rng(1) % for reproducibility
number_cores = 30;
if isempty(gcp('nocreate'))
    parpool(number_cores)
end

if ~exist('predictorNames', 'var')
    predictorNames = {'ROI_1', 'ROI_2', 'ROI_3', 'ROI_4', 'ROI_5', 'ROI_6'};
end
if ~exist('predictedNames', 'var')
    predictedNames = {'prop'};
end
if ~exist('num_permutations', 'var')
    num_permutations = 1;
end
if ~exist('test_title', 'var')
    test_title = '';
end
% features standartization
inputTable = trainingData;
features_data = table2array(trainingData(:,predictorNames));
features_data = bsxfun(@minus,features_data,nanmean(features_data,1));
features_data = bsxfun(@rdivide,features_data,nanstd(features_data,[],1));
features_data(isnan(features_data))=0; % replace missing data with the mean
inputTable(:,predictorNames)=array2table(features_data);


inputTable_tmp = inputTable;
validationAccuracy=nan(num_permutations,1);
if num_permutations>1
    h=waitbar(0,' ');
end
for iter = 1:num_permutations
    num_samples = numel(inputTable(:, predictedNames));
    pred_labels_fold=nan(num_samples,1);
    if iter>1 % first result is the original result.
        % For each permutation iteration shuffle the response variable
        inputTable_tmp(:, predictedNames) = inputTable(randperm(num_samples), predictedNames);
        waitbar_title = sprintf('%s\nRunning permutation iteration number %i out of %i',test_title,iter,num_permutations);
        waitbar(iter/num_permutations,h,waitbar_title);
    end
    parfor  leave_out = 1:num_samples
        test_data = (1:num_samples) == leave_out;
        train_data = (1:num_samples) ~= leave_out;
        predictors = inputTable_tmp(train_data,predictorNames);
        response =  inputTable_tmp(train_data,predictedNames);
        % Run SVM training
        regressionSVM = fitrsvm(predictors, response, ...
            'KernelFunction', 'gaussian', ...
            'PolynomialOrder', [], ...
            'KernelScale', 'auto', ...
            'BoxConstraint', 1, ...
            'Standardize', false);
        % CV prediction
        data2test = inputTable_tmp(test_data,predictorNames);
        pred_labels_fold(leave_out) = predict(regressionSVM,data2test);
    end
    % Compute validation accuracy
    real_labels = table2array(inputTable_tmp(:,predictedNames));
    validationAccuracy(iter) = corr(pred_labels_fold,real_labels);
end

Accuracy = validationAccuracy(1); % CV accuracy of the real model
if num_permutations>1
    close(h)
    p = nanmean(validationAccuracy(2:end)>=validationAccuracy(1)); % proportion of permuted model with similar or better accuracy
else
    p=nan;
end

% Create an output SVM model with all samples
predictors = inputTable(:,predictorNames);
response = inputTable(:,predictedNames);
trainedClassifier = fitrsvm(predictors, response, ...
    'KernelFunction', 'gaussian', ...
    'PolynomialOrder', [], ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', false);
data_norm = inputTable;
%W = trainedClassifier.SupportVectors' * full(trainedClassifier.SupportVectorLabels);
W=[];
