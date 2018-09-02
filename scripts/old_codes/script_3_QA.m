
clear 
close all

% set environment
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin']);

Subjects=001; % select subjects

% these are the bet default values - change  if you wish



script_start_time=GetSecs;
total_num_of_QA=0; % hoe many images need
QA_completed=0;

% loop over file - and count
for i=1:length(Subjects)
    if Subjects(i)<10
        sub_name=['sub00',num2str(Subjects(i))];
    else
        sub_name=['sub0',num2str(Subjects(i))];
    end
    
    BOLD_dirs=dir(['./',sub_name,'/BOLD/task*']); % find all BOLD Directories
    % Count number of BOLD files to BET
    for j=1:length(BOLD_dirs)
        BOLD_dir=[pwd,'/',sub_name,'/BOLD/',BOLD_dirs(j).name];
        %check if there is already a brain.nii file in the BOLD folder
        check_is_there_QA=length(dir([BOLD_dir,'/QA*']));
        if check_is_there_QA==0
            total_num_of_QA=total_num_of_QA+1;
        end
        
    end
    
end

% loop over files - and do BET

for i=1:length(Subjects)
    if Subjects(i)<10
        sub_name=['sub00',num2str(Subjects(i))];
    else
        sub_name=['sub0',num2str(Subjects(i))];
    end

    BOLD_dirs=dir(['./',sub_name,'/BOLD/task*']); % find all BOLD Directories
    % for all BOLD files to BET
    for j=1:length(BOLD_dirs)
        BOLD_dir=[pwd,'/',sub_name,'/BOLD/',BOLD_dirs(j).name];
        %check if there is already a brain.nii file in the BOLD folder
        check_is_there_QA=length(dir([BOLD_dir,'/QA*']));
        if check_is_there_QA==0
            [sys,~]=system(['python /Users/tomsalomon/Documents/MRI_faces/fmriqa-master/fmriqa.py ',BOLD_dir,'/bold_mcf.nii.gz 2']);        

        % once completed, estimate remaining time to finish script
        QA_completed=QA_completed+1;
        time_passed=GetSecs-script_start_time;
        average_processing_time=time_passed/QA_completed;
        fprintf('\n\nFininshed %s, %s. Time passed: %.1f minutes',sub_name,BOLD_dirs(j).name,time_passed/60)
        fprintf('\n%.0f out of %.0f runs completed at an average processing time of %.1f seconds.',QA_completed,total_num_of_QA,average_processing_time)
        fprintf('\nEstimated time left: %.1f minutes\n',(total_num_of_QA-QA_completed)*average_processing_time/60)
        end
    end
    
end

fprintf('\nDone! All BOLD images underwent QA\n');
