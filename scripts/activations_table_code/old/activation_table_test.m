%!/bin/sh

% activation_table.sh
%_____________________
% code that creates the MNI tables/peaks with the HarvardOxford-atlas locations to use in papers
% requires: folder-"activations_table_code" with the "activation_table.sh" script and subfolder "roifolder" with all the atlas ROIs

% commenting legend :
% comment
%! important comment
%+ silenced script

%  set cluster2MNI, 0=MNI atlas to your
%+ cluster2MNI = 0

% set path to folder-"activations_table_code
code_path="/export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/"
study_path="/export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/models/"
refernce_file_full_path="/export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/models/model006/group/group_task002_cope1.gfeat/cope1.feat/cluster_mask_zstat1.nii.gz"

%! set these
declare -a models=("006")
declare -a tasks=("002")
declare -a copes=("1")
declare -a contrasts=("1")



% transform the HarvardOxford-atlas (MNI) to your cluster dimentions
% if all of your images are the same dimentions this only need to be done once
%----------------------------------------------------------------
mkdir "$code_path"myroifolder
for ROI in `ls -d "$code_path"roifolder/*.nii.gz | xargs -n 1 basename`
    do
    # change dimentions
    flirt -in "$code_path"roifolder/$ROI -ref $refernce_file_full_path  -applyxfm -usesqform -out "$code_path"myroifolder/$ROI
    # re binerize
    fslmaths "$code_path"myroifolder/$ROI -thr 0.5 -bin "$code_path"myroifolder/$ROI
    # current ROI
    echo $ROI
done


for model in  "${models[@]}"
    do
    for task in  "${tasks[@]}"
        do
        for cope in  "${copes[@]}"
            do
            for contrast in  "${contrasts[@]}"
                do
                %% 1) make the binarized clusters:
                
                % create cluster mask,if there is no "cluster_mask_zstat%.nii.gz" already
                % ! doing it to cope%.nii.gz or zstat%.nii.gz doesn't give the same result
                %+  cluster -i thresh_zstat1.nii.gz -t 2.3 --oindex=cluster_mask_thresh_zstat1.nii.gz
                
                %% 2) extract number of voxels per HOA ROI
                N_clusters="$(fslstats "$study_path"model"$model"/group/group_task"$task"_cope1.gfeat/cope"$cope".feat/cluster_mask_zstat"$contrast".nii.gz -R | cut -d ' ' -f 2)"
                for  ((cluster_num=1; cluster_num<=N_clusters; i++))
                    do
                    % one mask per cluster
                    
                    mri_binarize --i cluster_mask_zstat1.nii.gz --match 1 --o cluster_mask_zstat1_cluster1.nii.gz
                    %open txt
                    echo roi numvox > cluster_mask_zstat1_cluster1.txt
                    
                    %within current cluster, compare voxels with atlas masks one at a time
                    %for HOA (HarvardOxford-atlas)
                    for ROI in  `ls -d "$code_path"myroifolder/*.nii.gz | xargs -n 1 basename`
                        do
                        fslmaths cluster_mask_zstat1_cluster1.nii.gz -mas  "$code_path"myroifolder/$ROI tmp.nii.gz
                        echo $ROI `fslstats tmp.nii.gz -V | awk '{print $1}'`>>  test.txt
                    end
                end %cluster_num
            end %contrast
        end %cope
    end %task
end %model

%% 3) once you have test files, use the make_HOA_activation_tables.R to make the table

