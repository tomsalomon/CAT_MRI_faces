%CREATE_BOLD_BRAIN
% this script creates brain images (skull stripped) from the preproc and
% brainmask images there are the output of fmriprep (version 1.0.0-rc2)
%
% subjects, sessions and tasks should include the 'sub-' or 'ses-' or
% 'task-' string, and be a cell (unless they are empty for all
% subjects/sessions/tasks)

% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

output_path = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives';
fmriprep_path = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/fmriprep';
sessions = {'ses-01', 'ses-02'};
tasks = {'task-responsetostim','task-training','task-probe','task-localizer'};
number_of_runs_per_task=[2,8,4,2];

subjects = dir([fmriprep_path '/sub-*']);
dirs = [subjects.isdir];
subjects = {subjects(dirs).name};
% note that the strings will contain the 'sub-'

for subject_ind = 1:length(subjects)
    for session_ind = 1:length(sessions)
        for task_ind = 1:length(tasks)
            for run_ind = 1:number_of_runs_per_task(task_ind)
                curr_fmriprep_dir = [fmriprep_path '/' subjects{subject_ind} '/' sessions{session_ind} '/func'];
                curr_output_dir = [output_path '/' subjects{subject_ind} '/' sessions{session_ind}];
                if ~isdir(curr_output_dir)
                    mkdir(curr_output_dir);
                end
                preproc_file = [curr_fmriprep_dir '/' subjects{subject_ind} '_' sessions{session_ind} '_' tasks{task_ind} '_run-0' num2str(run_ind) '_bold_space-MNI152NLin2009cAsym_preproc.nii.gz'];
                brainmask_file = [curr_fmriprep_dir '/' subjects{subject_ind} '_' sessions{session_ind} '_' tasks{task_ind} '_run-0' num2str(run_ind) '_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz'];
                output_file = [curr_output_dir '/' subjects{subject_ind} '_' sessions{session_ind} '_' tasks{task_ind} '_run-0' num2str(run_ind) '_bold_space-MNI152NLin2009cAsym_preproc_brain.nii.gz'];
                try
                    system(['fslmaths ' preproc_file ' -mul ' brainmask_file ' ' output_file]);
                    fprintf(['finished ' subjects{subject_ind} ' ' sessions{session_ind} ' ' tasks{task_ind} ' run 0' num2str(run_ind) ' in ' num2str(toc) '\n']);
                catch
                    warning(['could not calculate bold brain image for ' subjects{subject_ind} ' ' sessions{session_ind} ' ' tasks{task_ind}]);
                    continue;
                end
            end
        end
    end
end