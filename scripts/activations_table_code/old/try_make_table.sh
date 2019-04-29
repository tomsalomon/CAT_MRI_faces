#!/bin/sh
#first argument is the clustered *.nii.gz, the second argument is the number of clusters

for s in {1..$2}
do

# Program to binarize a volume (or volume-encoded surface file)
# mri_binarize --i <invol> --o <outvol>
#--match Use match instead of threshold
#Binarize based on matching volumes. Any number of match values can be specified. Cannot be used with --min/--max.
	mri_binarize --i thresh_zstat1.nii.gz_cluster.nii.gz --match $s --o ${1}_cluster${s}.nii.gz
	echo roi numvox > ${1}_cluster${s}.txt
	
    for r in `ls -d roifolder/*.nii.gz`
		do
		fslmaths ${1}_cluster${s}.nii.gz -mas $r tmp.nii.gz
		echo $r `fslstats tmp.nii.gz -V | awk '{print $1}'`>> ${1}_cluster${s}.txt
		done
done		
