function [best_combination,best_combination_score] = find_best_match (input_mat,threshold)
% This functions receives a matrix in which each column represent an ROI
% and each row represents a cluster. Each cell represents the cluster's
% match to the ROI. The function allocates the one cluster per ROI,
% maximizing the total sum of matching scores for the entire dataset.
%
% Example, for:
%           ROI1    ROI2    ROI3
% Cluster1  0.8     0.6     0
% Cluster2  0.5     0       0
%
% The optimal solution is: [2, 1, NaN]; i.e ROI_1 = Cluster1; ROI2 =
% Cluster2; ROI3 = undefined.

if nargin < 2
    threshold = 0;
end

input_mat(isnan(input_mat)) = 0; % replace NaN with zeros
[mat_size] = size(input_mat);
num_rows = mat_size(1);
num_cols = mat_size(2);
if num_rows < num_cols % if there are less rows than columns add zeroed rows
    mat = zeros(num_cols);
    mat(1:num_rows,:)=input_mat;
    num_rows = num_cols;
else
    mat=input_mat;
end


combinations = permn(1:num_rows,num_cols);

% keep only combinations where each ROI has a unique clusters.
for row_index = 1:num_rows
    count_appearance_in_combination = sum(combinations == row_index,2);
    combinations = combinations (count_appearance_in_combination <= 1, :);
end

combinations_score_mat = zeros(size(combinations));
for col_index = 1:num_cols
    mat_col = mat(:,col_index);
    combinations_score_mat(:,col_index) = mat_col(combinations(:,col_index));
end
combinations_scores = sum(combinations_score_mat,2);
[~,best_combination_ind] = max(combinations_scores);
best_combination = combinations(best_combination_ind,:);
best_combination_score = combinations_score_mat(best_combination_ind,:);
% remove results below threshold
best_combination(best_combination_score <= threshold) = 0;
best_combination_score(best_combination_score <= threshold) = 0;

end