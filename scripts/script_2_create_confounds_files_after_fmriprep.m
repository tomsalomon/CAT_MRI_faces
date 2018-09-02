%function num_bad_volumes = create_confounds_files_after_fmriprep(main_input_path,main_output_path,fd_threshold,subjects,sessions,tasks)
%CREATE_CONFOUNDS_FILES_AFTER_FMRIPREP
% created on August 2017 by rotem Botvinik Nezer
% Modified on October 2017 by Tom Salomon
%
% this function creates confound txt files in fsl format, based on the
% confounds.tsv created by fmriprep (version 1.0.0-rc2) and the parameters we decided to use.
% the output is txt file named confounds with the following columns (no
% titles):
% std dvars, abs dvars, voxelwise std dvars, six motion parameters
% (translation and rotation each in 3 directions)
% in addition, there an additional column for each volume that should be
% extracted due to FD>fd_threshold (default value for fd threshold is 0.9).
% this function also returns as output the number of "thrown" volumes for
% each subject (based on the fd value and threshold) to the num_bad_volumes
% variable
%
% if specific subjects / sessions / tasks are specified, only them
% will be calculated. Else, the default is all subjects, sessions, tasks
% and runs. If you want all subjects/tasks/sessions you can put an empty value in the
% relevant variable
% subjects, sessions and tasks should include the 'sub-' or 'ses-' or
% 'task-' string, and be a cell (unless they are empty for all
% subjects/sessions/tasks)

clear;
tic

% set FSL environment
setenv('FSLDIR','/share/apps/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);


main_output_path = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives';
main_input_path = '/export/home/DATA/schonberglab/MRI_faces/analysis/BIDS/derivatives/fmriprep';
tasks = {'task-responsetostim','task-training','task-probe','task-localizer'};
number_of_runs_per_task=[2,8,4,2];
number_of_runs_per_task_ses_02=[1,0,4,2];
sessions = {'ses-01','ses-02'};

subjects = dir([main_input_path '/sub-*']);
dirs = [subjects.isdir];
subjects = {subjects(dirs).name};
% note that the strings will contain the 'sub-'

fd_threshold = 0.9;

% define table headings
num_bad_volumes_titles=cell(1,sum([number_of_runs_per_task,number_of_runs_per_task_ses_02]));
ind=1;
for task_ind = 1:length(tasks)
    for run_ind = 1:number_of_runs_per_task(task_ind)
        num_bad_volumes_titles{ind}=['ses-01_',tasks{task_ind},'_run-0',num2str(run_ind)];
        ind=ind+1;
    end
end
for task_ind = 1:length(tasks)
    for run_ind = 1:number_of_runs_per_task_ses_02(task_ind)
        num_bad_volumes_titles{ind}=['ses-02_',tasks{task_ind},'_run-0',num2str(run_ind)];
        ind=ind+1;
    end
end
        
num_bad_volumes=cell(1+length(subjects),1+length(num_bad_volumes_titles));
num_bad_volumes(1,:) = {'sub',num_bad_volumes_titles{:}};
num_bad_volumes(2:end,1) = subjects;

for subject_ind = 1:length(subjects)
    for session_ind = 1:length(sessions)
        col_ind_for_bad_vols=2 + (session_ind-1)*sum(number_of_runs_per_task);
        for task_ind = 1:length(tasks)
            for run_ind = 1:number_of_runs_per_task(task_ind)
                curr_input_dir = [main_input_path '/' subjects{subject_ind} '/' sessions{session_ind} '/func'];
                curr_output_dir = [main_output_path '/' subjects{subject_ind} '/' sessions{session_ind}];
                
                filename = [subjects{subject_ind} '_' sessions{session_ind} '_' tasks{task_ind} '_run-0' num2str(run_ind) '_bold_confounds.tsv'];
                input_filename = [curr_input_dir '/' filename];
                output_filename = [curr_output_dir '/' filename];
                % read confounds file
                try
                    confounds = tdfread(input_filename);
                catch
                    warning(['could not open confounds file for ' subjects{subject_ind} ' ' sessions{session_ind} ' ' tasks{task_ind}]);
                    continue;
                end
                if ~isdir(curr_output_dir)
                    mkdir(curr_output_dir);
                end
                fprintf(['read confounds file of ' subjects{subject_ind} ' ' sessions{session_ind} ' ' tasks{task_ind} ' run 0' num2str(run_ind) ' in ' num2str(toc) '\n']);
                % create new confounds array
                new_confounds(:,1) = cellstr(confounds.stdDVARS);
                new_confounds(:,2) = cellstr(confounds.non0x2DstdDVARS);
                new_confounds(:,3) = cellstr(confounds.vx0x2DwisestdDVARS);
                new_confounds(1,1:3) = {'0'};
                new_confounds(:,1:3) = cellfun(@str2num,new_confounds(:,1:3),'UniformOutput',0);
                new_confounds(:,4) = num2cell(confounds.X);
                new_confounds(:,5) = num2cell(confounds.Y);
                new_confounds(:,6) = num2cell(confounds.Z);
                new_confounds(:,7) = num2cell(confounds.RotX);
                new_confounds(:,8) = num2cell(confounds.RotY);
                new_confounds(:,9) = num2cell(confounds.RotZ);
                FD = cellstr(confounds.FramewiseDisplacement);
                FD{1} = '0';
                FD = cellfun(@str2num,FD);
                bad_vols = FD>fd_threshold;
                num_bad_vols = sum(bad_vols);
%                 col_ind_for_bad_vols = inds_for_bad_vols(find(strcmp(tasks{task_ind},tasks)),(find(strcmp(sessions{session_ind},sessions))-1)*4+run_ind);
                num_bad_volumes{subject_ind+1,col_ind_for_bad_vols} = num_bad_vols;
                if num_bad_vols == 0
                    fprintf('no bad volumes, based on fd threshld %.2f\n',fd_threshold);
                else
                    fprintf('found %d bad volumes with fd > %.2f\n', num_bad_vols,fd_threshold);
                    bad_vols_loc = find(bad_vols);
                    for vol_ind = 1:length(bad_vols_loc)
                        new_confounds(:,end+1) = {0};
                        new_confounds(bad_vols_loc(vol_ind),end) = {1};
                    end
                end
                
                % save output confounds file
                %                 fid = fopen(output_filename,'w'); % if their are n/a values
                %                 fprintf(fid,'%s\t',new_confounds{1,1:3}); % fits the current order of parameters
                %                 fprintf(fid, '%f\t',new_confounds{1,4:end});
                %                 fprintf(fid,'\n');
                %                 fclose(fid);
                dlmwrite(output_filename,new_confounds,'delimiter','\t');
                
                fprintf(['finished ' subjects{subject_ind} ' ' sessions{session_ind} ' ' tasks{task_ind} ' run 0' num2str(run_ind) ' in ' num2str(toc) '\n']);
                clear confounds new_confounds;
                col_ind_for_bad_vols=col_ind_for_bad_vols+1;
            end
        end
    end
end

