clear;

% Define these variables
group_randomise_path='/export/home/DATA/schonberglab/MRI_faces/MRI/models/group_2017_06_13/randomise/';
task_num=3;

switch task_num
    case 1
        task_name='task001';
        num_of_level1_copes=24;
        num_of_level2_copes=3;
    case 2
        task_name='task002';
        num_of_level1_copes=25;
        num_of_level2_copes=[];
    case 3
        task_name='task003';
        num_of_level1_copes=30;
        num_of_level2_copes=1;
    case 4
        task_name='localizer';
        num_of_level1_copes=[];
end

results=cell(num_of_level1_copes*num_of_level2_copes,2);
ind=1;

group_randomise_path=[group_randomise_path,task_name,'/'];

for level_1_cope=1:num_of_level1_copes
    level1_cope_name=['cope',num2str(level_1_cope)];
    
    for level_2_cope=1:num_of_level2_copes
        level2_cope_name=['cope',num2str(level_2_cope)];
        results{ind,1}=[level1_cope_name,level2_cope_name];
        [~,results{ind,2}]=system(['fslstats ',group_randomise_path,level1_cope_name,'/',level2_cope_name,'_tfce_corrp_tstat1.nii.gz -l 0.95 -v']);
        ind=ind+1;
    end
end

