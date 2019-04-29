#!/bin/sh

# activation_table.sh
#_____________________
# code that creates the MNI tables/peaks with the HarvardOxford-atlas locations to use in papers

# !!!  set cluster2MNI, 0=MNI atlas to your 


for model
    for task
        for cope
            for contrast
                ## 1) make the binarized clusters:
                
                # create cluster mask,if there is no "cluster_mask_zstat#.nii.gz" already
                # ! doing it to cope#.nii.gz or zstat#.nii.gz doesn't give the same result
                cluster -i thresh_zstat1.nii.gz -t 2.3 --oindex=cluster_mask_thresh_zstat1.nii.gz
                
                ## 2) use the attached make_table.sh and roifolder to extract number of voxels per HOA ROI
                #./make_table.sh model001task001cope001_cluster 4    #that second number is the number of clusters
                for clusterId
                    # one mask per cluster
                    
                    mri_binarize --i cluster_mask_zstat1.nii.gz --match 1 --o cluster_mask_zstat1_cluster1.nii.gz
                    #open txt
                    echo roi numvox > cluster_mask_zstat1_cluster1.txt
                    
                    # if your cluster mask is not in MNI 2*2*2 space, reshpe it to it
                    # general: flirt -in your_input_img -ref /share/apps/fsl/data/standard/MNI152_T1_2mm.nii.gz -applyxfm -usesqform -out output_img_name
                    
                    # cluster to MNI space (to confirm to the MNI HarvardOxford-atlas)
                    flirt -in cluster_mask_zstat1_cluster1.nii.gz  -ref /share/apps/fsl/data/standard/MNI152_T1_2mm.nii.gz -applyxfm -usesqform -out cluster_mask_zstat1_cluster1_mni.nii.gz
                    
                    # if you want to transform the HarvardOxford-atlas (MNI) to cluster use the "MNI " )
                    for ROI in `ls -d /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activation_table_code/roifolder/*.nii.gz`
                        do
                        flirt -in $ROI -ref /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/models/model006/group/group_task002_cope1.gfeat/cope1.feat/cluster_mask_zstat1_cluster1.nii.gz  -applyxfm -usesqform -out output_img_name
                        done
                        
                        
                        
                        # make the reshaped image binary again (the flirt does an interpulation)
                        # general: fslmaths <your_output_from_the_previous_command> -thr 0.5 -bin output_name
                        fslmaths cluster_mask_zstat1_cluster1_mni.nii.gz -thr 0.5 -bin binary_cluster_mask_zstat1_cluster1_mni.nii.gz
                        
                        
                        #within current cluster, compare voxels with atlas masks one at a time
                        #for HOA (HarvardOxford-atlas)
                        for ROI in `ls -d /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activation_table_code/roifolder/*.nii.gz`
                            do
                            fslmaths cluster1_mask_zstat1.nii.gz -mas $ROI tmp.nii.gz
                            echo $ROI `fslstats tmp.nii.gz -V | awk '{print $1}'`>> cluster1_mask_zstat1.txt
                            done
                            
                        done
                    done
                done
            done
        done
    done
    
    ## 3) once you have test files, use the make_HOA_activation_tables.R to make the table
    
    
    
 locations to use in papers

native_to_mni = 0;

for model in 
do
    for task in
    do
        for cope in
	do
            for contrast in
	    do
		echo $model $task $cope $contrast

                ## 1) make the binarized clusters:
                
                # create cluster mask,if there is no "cluster_mask_zstat#.nii.gz" already
                # ! doing it to cope#.nii.gz or zstat#.nii.gz doesn't give the same result
                cluster -i thresh_zstat1.nii.gz -t 2.3 --oindex=cluster_mask_thresh_zstat1.nii.gz
                
                ## 2) use the attached make_table.sh and roifolder to extract number of voxels per HOA ROI
                #./make_table.sh model001task001cope001_cluster 4    #that second number is the number of clusters
                for clusterId
                    # one mask per cluster
                    
                    mri_binarize --i cluster_mask_zstat1.nii.gz --match 1 --o cluster_mask_zstat1_cluster1.nii.gz
                    #open txt
                    echo roi numvox > cluster_mask_zstat1_cluster1.txt
                    
                    # if your cluster mask is not in MNI 2*2*2 space, reshpe it to it
                    # general: flirt -in your_input_img -ref /share/apps/fsl/data/standard/MNI152_T1_2mm.nii.gz -applyxfm -usesqform -out output_img_name
                    
                    # cluster to MNI space (to confirm to the MNI HarvardOxford-atlas)
                    flirt -in cluster_mask_zstat1_cluster1.nii.gz  -ref /share/apps/fsl/data/standard/MNI152_T1_2mm.nii.gz -applyxfm -usesqform -out cluster_mask_zstat1_cluster1_mni.nii.gz
                    
                    # if you want to transform the HarvardOxford-atlas (MNI) to cluster use the "MNI " )
                    for ROI in `ls -d /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activation_table_code/roifolder/*.nii.gz`
                        do
                        flirt -in $ROI -ref /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/models/model006/group/group_task002_cope1.gfeat/cope1.feat/cluster_mask_zstat1_cluster1.nii.gz  -applyxfm -usesqform -out output_img_name
                        done
                        
                        
                        
                        # make the reshaped image binary again (the flirt does an interpulation)
                        # general: fslmaths <your_output_from_the_previous_command> -thr 0.5 -bin output_name
                        fslmaths cluster_mask_zstat1_cluster1_mni.nii.gz -thr 0.5 -bin binary_cluster_mask_zstat1_cluster1_mni.nii.gz
                        
                        
                        #within current cluster, compare voxels with atlas masks one at a time
                        #for HOA (HarvardOxford-atlas)
                        for ROI in `ls -d /export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activation_table_code/roifolder/*.nii.gz`
                            do
                            fslmaths  binary_cluster_mask_zstat1_cluster1_mni.nii.gz -mas $ROI tmp.nii.gz
                            echo $ROI `fslstats tmp.nii.gz -V | awk '{print $1}'`>> cluster_mask_zstat1_cluster1.txt
                            done
                            
                        done
                    done
                done
            done
        done
    done
    
    ## 3) once you have test files, use the make_HOA_activation_tables.R to make the table
    
 
