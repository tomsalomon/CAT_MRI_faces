% create environment
p = path;
cd .. 
%cd ..
%cd DATA
%addpath(genpath('schonberglab/MRI_faces'));
addpath(genpath('/export/home/DATA/schonberglab/Michal_Pred'));
addpath(genpath('/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives'));

% Path for Harvard-Oxford structural atlas labels and names - need to add 1
% to the number of the label
atlas_path = '/export/share/apps/fsl/data/atlases/HarvardOxford-Cortical.xml';
%main_dir = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives';
main_dir = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives';
cases_list = dir(main_dir);

outdir = '/export/home/DATA/schonberglab/Michal_Pred/MRI_faces_analysis/localizer_clusters';
outdir=    'DATA/schonberglab/Michal_Pred/MRI_faces_analysis/localizer_clusters';

file_name = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/sub-001/ses-01/model/model001/sub-001_ses-01_task-localizer.gfeat/cope3.feat/cluster_mask_zstst1.nii.gz';
files = gunzip('/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/sub-001/ses-01/model/model001/sub-001_ses-01_task-localizer.gfeat/cope3.feat/cluster_mask_zstat1.nii.gz',outdir);

cd main_dir
cd MRI_faces
%%
% from matlab 2017b
%V = niftread('/export/home/DATA/schonberglab/Michal_Pred/cluster_mask_zstat1.nii');

%% ______________________________________________________________
% From code count_sig_cluster_localiser
%clear;

% Define these variables
task_num=4;
ses_num=1;
Subjects=1:50;
experiment_path='/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/';
%group_analysis_path=[experiment_path,'models/model001/ses-',sprintf('%02.f',ses_num),'/group_analysis/'];

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

%results=[Subjects',zeros(size(Subjects'))];
sub_path = dir([experiment_path,'sub-0*']);
%subject_path=dir([group_analysis_path,'group_',task_name,'*',strrep(num2str(zthresh),'.','_')]);
%subject_path=[group_analysis_path,subject_path.name];
analysis_progress=0;
h = waitbar(analysis_progress,'Analyzing..');
% cd outdir
for i=Subjects(3:end)
    i
   full_sub_path = [experiment_path,sub_path(i).name,'/ses-01/model/model001/',strcat(sub_path(i).name,'_ses-01_task-localizer.gfeat/cope3.feat/cluster_mask_zstat1.nii.gz')];
   new_sub_path = [outdir,'/',sub_path(i).name,'_ses-01_localizer_cluster_mask_zstat1_bin.nii.gz'];
%    savename = [outdir,];
   % nii_image=[subject_path,sprintf('/cope%i.gfeat/cope%i.feat/cluster_mask_zstat%i.nii.gz',cope_lev_1(sub),cope_lev_2(sub),cope_lev_3(sub))];
    %change this!!!!
    if~exist(new_sub_path,'file')
       % system('cd ','..\..')
        system(['cd ',outdir])
        [~,tmp]=system(['fslmaths ',full_sub_path,' -bin ',new_sub_path]);
%         [~,tmp]=system(['fslstats ',nii_image,' -p 100']);
%         results(sub,4)=str2double(tmp);
%     else
%         results(sub,4)=nan;
    end
%     analysis_progress=sub/length(cope_lev_1);
%     waitbar(analysis_progress,h);
end
% close(h)