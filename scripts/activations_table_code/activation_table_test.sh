#!/bin/sh

# activation_table.sh
#_____________________
# code that creates the MNI tables/peaks with the HarvardOxford-atlas locations to use in papers
# requires: folder-"activations_table_code" with the "activation_table.sh" script and subfolder "roifolder" with all the atlas ROIs

# commenting legdone :
# comment
#! important comment
#+ silenced script

#  set cluster2MNI, 0=MNI atlas to your
#+ cluster2MNI = 0

# set path to folder-"activations_table_code
code_path="/export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/"
output_path=${code_path}output/
mkdir ${output_path}
study_path="/export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/models/"
refernce_file_full_path="/export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/models/model006/group/group_task002_cope1.gfeat/cope1.feat/cluster_mask_zstat1.nii.gz"

#! set these
declare -a models=("010")
declare -a tasks=("002" "003")
declare -a copes1=("1")
declare -a copes2=("1")
declare -a contrasts=("1" "2")



# transform the HarvardOxford-atlas (MNI) to your cluster dimentions
# if all of your images are the same dimentions this only need to be done once
#----------------------------------------------------------------

#mkdir "$code_path"myroifolder
#for ROI in `ls -d "$code_path"roifolder/*.nii.gz | xargs -n 1 basename`
#    do
#    # change dimentions
#    flirt -in "$code_path"roifolder/$ROI -ref $refernce_file_full_path  -applyxfm -usesqform -out "$code_path"myroifolder/$ROI
#    # re binerize
#    fslmaths "$code_path"myroifolder/$ROI -thr 0.5 -bin "$code_path"myroifolder/$ROI
#    # current ROI
#    echo $ROI
#done


for model in  "${models[@]}"
    do
    for task in  "${tasks[@]}"
        do
	for cope1 in "${copes1[@]}"
	do
            for cope2 in  "${copes2[@]}"
            do
		for contrast in  "${contrasts[@]}"
                do
                    echo "##############################"
		    echo model ${model} task ${task} cope1 ${cope1} cope2 ${cope2} contrast ${contrast}
		    echo "##############################"
		    ## 1) make the binarized clusters:
                    
                    # create cluster mask,if there is no "cluster_mask_zstat#.nii.gz" already
                    # ! doing it to cope#.nii.gz or zstat#.nii.gz doesn't give the same result
                    #+  cluster -i thresh_zstat1.nii.gz -t 2.3 --oindex=cluster_mask_thresh_zstat1.nii.gz
                    
                    ## 2) extract number of voxels per HOA ROI
                    cluster_mask_path=""$study_path"model"$model"/group/group_task"$task"_cope"$cope1".gfeat/cope"$cope2".feat/cluster_mask_zstat"$contrast""
		    output_name=model${model}_task${task}_level1cope${cope1}_level2cope${cope2}_contrast${contrast}
		    N_clusters="$(fslstats ${cluster_mask_path} -R | cut -d ' ' -f 2)"
		    #convert float to int
		    N_clusters=${N_clusters/.*}
		    
		    for  ((cluster_num=1; cluster_num<=N_clusters; cluster_num++))
                    do
			echo "#########################"
			echo cluster num ${cluster_num}
			echo "#########################"

			current_filename=${output_path}${output_name}_cluster${cluster_num}
			# one mask per cluster
			mri_binarize --i ${cluster_mask_path}.nii.gz --match $cluster_num --o ${current_filename}.nii.gz
			#open txt
			echo roi numvox > ${current_filename}.txt
			
			#within current cluster, compare voxels with atlas masks one at a time
			#for HOA (HarvardOxford-atlas)
			for ROI in  `ls -d "$code_path"myroifolder/*.nii.gz | xargs -n 1 basename`
                        do
                            fslmaths ${current_filename}.nii.gz -mas  "$code_path"myroifolder/$ROI tmp.nii.gz
                            echo $ROI `fslstats tmp.nii.gz -V | awk '{print $1}'`>>  ${current_filename}.txt
			done
                    done #cluster_num
		done #contrast
            done #copes1
	done #copes2
    done #task
done #model

## 3) once you have test files, use the make_HOA_activation_tables.R to make the table

