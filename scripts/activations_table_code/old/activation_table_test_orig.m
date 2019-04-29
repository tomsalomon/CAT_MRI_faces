#!/bin/sh

# activation_table.sh
#_____________________
# code that creates the MNI tables/peaks with the HarvardOxford-atlas locations to use in papers
# requires: folder-"activations_table_code" with the "activation_table.sh" script and subfolder "roifolder" with all the atlas ROIs

# commenting legend :
 # comment
 #! important comment
 #+ silenced script 

#  set cluster2MNI, 0=MNI atlas to your 
#+ cluster2MNI = 0

# set path to folder-"activations_table_code


 # transform the HarvardOxford-atlas (MNI) to your cluster dimentions
 # if all of your images are the same dimentions this only need to be done once
 #!!! add if and move outside the loop (only need once)
 #----------------------------------------------------------------
for ROI in `ls -d /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/roifolder/*.nii.gz | xargs -n 1 basename`
    do
    flirt -in /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/roifolder/$ROI -ref /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/models/model006/group/group_task002_cope1.gfeat/cope1.feat/cluster_mask_zstat1_cluster1.nii.gz  -applyxfm -usesqform -out /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/myroifolder/$ROI
                        
     fslmaths /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/myroifolder/$ROI -thr 0.5 -bin /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/myroifolder/$ROI
     done


for model in 
    for task in
        for cope in
            for contrast in
                ## 1) make the binarized clusters:
                
                # create cluster mask,if there is no "cluster_mask_zstat#.nii.gz" already
                # ! doing it to cope#.nii.gz or zstat#.nii.gz doesn't give the same result
                #+  cluster -i thresh_zstat1.nii.gz -t 2.3 --oindex=cluster_mask_thresh_zstat1.nii.gz
                
                ## 2) extract number of voxels per HOA ROI
		N_clusters="$(fslstats cluster_mask_zstat1.nii.gz -R | cut -d ' ' -f 2)"

                for clusterId
                    # one mask per cluster
                    
                    mri_binarize --i cluster_mask_zstat1.nii.gz --match 1 --o cluster_mask_zstat1_cluster1.nii.gz
                    #open txt
                    echo roi numvox > cluster_mask_zstat1_cluster1.txt
                    
                    # if your cluster mask is not in MNI 2*2*2 space, you have to make one confirm to the other
		    
                    # cluster to MNI space (to confirm to the MNI HarvardOxford-atlas)
		    #----------------------------------------------------------------
                    #+ flirt -in cluster_mask_zstat1_cluster1.nii.gz  -ref /share/apps/fsl/data/standard/MNI152_T1_2mm.nii.gz -applyxfm -usesqform -out cluster_mask_zstat1_cluster1_mni.nii.gz
                    
		    # make the reshaped image binary again (the flirt does an interpulation)
                    #+  fslmaths cluster_mask_zstat1_cluster1_mni.nii.gz -thr 0.5 -bin binary_cluster_mask_zstat1_cluster1_mni.nii.gz

		    #within current cluster, compare voxels with atlas masks one at a time
                    #+    for ROI in `ls -d /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activation_table_code/roifolder/*.nii.gz`
                    #+        do
                    #+        fslmaths cluster1_mask_zstat1.nii.gz -mas $ROI tmp.nii.gz
                    #+        echo $ROI `fslstats tmp.nii.gz -V | awk '{print $1}'`>> cluster1_mask_zstat1.txt
                    #+    done


 
                        
                        
                        #within current cluster, compare voxels with atlas masks one at a time
                        #for HOA (HarvardOxford-atlas)
                        for ROI in  `ls -d /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/myroifolder/*.nii.gz | xargs -n 1 basename`
                            do
                            fslmaths cluster_mask_zstat1_cluster1.nii.gz -mas  /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/myroifolder/$ROI tmp.nii.gz
                            echo $ROI `fslstats tmp.nii.gz -V | awk '{print $1}'`>>  test.txt
                        done
                            
                        
                    done
                done
            done
        done
    done
    
    ## 3) once you have test files, use the make_HOA_activation_tables.R to make the table
    
    