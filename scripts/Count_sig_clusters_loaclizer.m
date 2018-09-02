clear;

% Define these variables
task_num=4;
ses_num=1;
Subjects=1:50;
experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/';
group_analysis_path=[experiment_path,'models/model001/ses-',sprintf('%02.f',ses_num),'/group_analysis/'];
zthresh=3.1;

switch task_num
    case 1
        task_name='task-responsetostim';
        num_of_level1_copes=27;
        num_of_level2_copes=5;
        num_of_level3_copes=4;
    case 2
        task_name='task-training';
        num_of_level1_copes=25;
        num_of_level2_copes=13;
        num_of_level3_copes=4;
    case 3
        task_name='task-probe';
        num_of_level1_copes=26;
        num_of_level2_copes=1;
        num_of_level3_copes=4;
    case 4
        task_name='task-localizer';
        num_of_level1_copes=[];
end

results=[Subjects',zeros(size(Subjects'))];
subject_path=dir([group_analysis_path,'group_',task_name,'*',strrep(num2str(zthresh),'.','_')]);
subject_path=[group_analysis_path,subject_path.name];
analysis_progress=0;
h = waitbar(analysis_progress,'Analyzing..');
for sub=Subjects
    nii_image=[subject_path,sprintf('/cope%i.gfeat/cope%i.feat/cluster_mask_zstat%i.nii.gz',cope_lev_1(sub),cope_lev_2(sub),cope_lev_3(sub))];
    %change this!!!!
    if~isempty(dir(nii_image))
        [~,tmp]=system(['fslstats ',nii_image,' -p 100']);
        results(sub,4)=str2double(tmp);
    else
        results(sub,4)=nan;
    end
    analysis_progress=sub/length(cope_lev_1);
    waitbar(analysis_progress,h);
end
close(h)


