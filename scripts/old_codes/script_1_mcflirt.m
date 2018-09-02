
% set FSL environment
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin']);

Subjects=001; % select subjects to be motion corrected

script_start_time=GetSecs;
total_num_of_BOLD=0;
BOLD_completed=0;

for i=1:length(Subjects)
    if Subjects(i)<10
        sub_name=['sub00',num2str(Subjects(i))];
    else
        sub_name=['sub0',num2str(Subjects(i))];
    end
    
    BOLD_dirs=dir(['./',sub_name,'/BOLD/task*']); % find all BOLD Directories
    
    % Count number of BOLD files to be motion corrected
    for BOLD=1:length(BOLD_dirs)
        BOLD_dir_path=[pwd,'/',sub_name,'/BOLD/',BOLD_dirs(BOLD).name];
        %check if there is already a mcf.nii file in the BOLD folder
        check_is_there_mcf=length(dir([BOLD_dir_path,'/*mcf.nii.gz']));
        if check_is_there_mcf==0
            total_num_of_BOLD=total_num_of_BOLD+1;
        end
    end
end

for i=1:length(Subjects)
    if Subjects(i)<10
        sub_name=['sub00',num2str(Subjects(i))];
    else
        sub_name=['sub0',num2str(Subjects(i))];
    end
    
    BOLD_dirs=dir(['./',sub_name,'/BOLD/task*']); % find all BOLD Directories
    
    for BOLD=1:length(BOLD_dirs)
        BOLD_dir_path=[pwd,'/',sub_name,'/BOLD/',BOLD_dirs(BOLD).name];
        %check if there is already a mcf.nii file in the BOLD folder
        check_is_there_mcf=length(dir([BOLD_dir_path,'/*mcf.nii.gz']));
        if check_is_there_mcf==0
            % Run mcflirt from terminal
            [sys,~]=system(['/usr/local/fsl/bin/mcflirt -in ',BOLD_dir_path,'/bold.nii.gz -plots -report']);
            
            % once completed, estimate remaining time to finish script
            BOLD_completed=BOLD_completed+1;
            time_passed=GetSecs-script_start_time;
            average_processing_time=time_passed/BOLD_completed;
            fprintf('\n\nFininshed %s, %s. Time passed: %.1f minutes',sub_name,BOLD_dirs(BOLD).name,time_passed/60)
            fprintf('\n%.0f out of %.0f runs completed at an average processing time of %.1f seconds.',BOLD_completed,total_num_of_BOLD,average_processing_time)
            fprintf('\nEstimated time left: %.1f minutes\n',(total_num_of_BOLD-BOLD_completed)*average_processing_time/60)
        end
    end
end

fprintf('\nDone! All BOLD files were motion corrected\n')