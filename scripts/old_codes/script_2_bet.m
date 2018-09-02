
clear all
close all

% set FSL environment
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin']);

Subjects=001; % select subjects to be motion corrected

% these are the bet default values - change  if you wish
Anatomy_BET_thresh=0.3;
BOLD_BET_thresh=0.3;


script_start_time=GetSecs;
total_num_of_BET=0; % hoe many images need
BET_completed=0;

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
        check_is_there_bet=length(dir([BOLD_dir,'/*brain.nii.gz']));
        if check_is_there_bet==0
            total_num_of_BET=total_num_of_BET+1;
        end
        
    end
    
    Anatomy_images=dir(['./',sub_name,'/anatomy/*.nii.gz']);
    % Count number of anatomy files to BET
    for j=1:length(Anatomy_images)
        Anatomy_image=[pwd,'/',sub_name,'/anatomy/',Anatomy_images(j).name];
        % check if there is already a brain.nii file in the BOLD folder
        check_is_there_bet=length(dir([Anatomy_image(1:end-7),'*brain.nii.gz']));
        % also test if the current fild is a bet file
        check_is_there_bet=sum([check_is_there_bet,strfind(Anatomy_image,'brain')]);
        if check_is_there_bet==0
            total_num_of_BET=total_num_of_BET+1;
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
    
    Anatomy_images=dir(['./',sub_name,'/anatomy/*.nii.gz']);
    % for all anatomy files to BET
    for j=1:length(Anatomy_images)
        Anatomy_image=[pwd,'/',sub_name,'/anatomy/',Anatomy_images(j).name];
        % check if there is already a brain.nii file in the BOLD folder
        check_is_there_bet=length(dir([Anatomy_image(1:end-7),'*brain.nii.gz']));
        % also test if the current fild is a bet file
        check_is_there_bet=sum([check_is_there_bet,strfind(Anatomy_image,'brain')]);
        if check_is_there_bet==0
            [sys,~]=system(['/usr/local/fsl/bin/bet ',Anatomy_image,'.nii.gz ',Anatomy_image(1:end-7),'_brain.nii.gz -f ',num2str(Anatomy_BET_thresh)]);        
        
         % once completed, estimate remaining time to finish script
        BET_completed=BET_completed+1;
        time_passed=GetSecs-script_start_time;
        average_processing_time=time_passed/BET_completed;
        fprintf('\n\nFininshed %s, %s. Time passed: %.1f minutes',sub_name,Anatomy_images(j).name,time_passed/60)
        fprintf('\n%.0f out of %.0f runs completed at an averge processing time of %.1f seconds.',BET_completed,total_num_of_BET,average_processing_time)
        fprintf('\nEstimated time left: %.1f minutes\n',(total_num_of_BET-BET_completed)*average_processing_time/60)
        end 
    end
    
    
    
    BOLD_dirs=dir(['./',sub_name,'/BOLD/task*']); % find all BOLD Directories
    % for all BOLD files to BET
    for j=1:length(BOLD_dirs)
        BOLD_dir=[pwd,'/',sub_name,'/BOLD/',BOLD_dirs(j).name];
        %check if there is already a brain.nii file in the BOLD folder
        check_is_there_bet=length(dir([BOLD_dir,'/*brain.nii.gz']));
        if check_is_there_bet==0
            [sys,~]=system(['/usr/local/fsl/bin/bet ',BOLD_dir,'/bold_mcf.nii.gz ',BOLD_dir,'/bold_mcf_brain.nii.gz -F -f ',num2str(BOLD_BET_thresh)]);        

        % once completed, estimate remaining time to finish script
        BET_completed=BET_completed+1;
        time_passed=GetSecs-script_start_time;
        average_processing_time=time_passed/BET_completed;
        fprintf('\n\nFininshed %s, %s. Time passed: %.1f minutes',sub_name,BOLD_dirs(j).name,time_passed/60)
        fprintf('\n%.0f out of %.0f runs completed at an average processing time of %.1f seconds.',BET_completed,total_num_of_BET,average_processing_time)
        fprintf('\nEstimated time left: %.1f minutes\n',(total_num_of_BET-BET_completed)*average_processing_time/60)
        end
    end
    
end

fprintf('\nDone! All Anatomy and BOLD images were Brain extracted\n')

%

%{

    % Set the BET thershold parameters
    BOLD_BET_thresh=0;
    
    
    Anatomy_images=dir([pwd,'/',sub_name,'/anatomy/*.nii.gz']); % find all Anatomy images
    BOLD_dirs=dir([pwd,'/',sub_name,'/BOLD/task*']); % find all BOLD Directories
    
    Anatomy_image=[pwd,'/',sub_name,'/Anatomy/highres001'];
    Anatomy_BET_thresh=input('\nSelect the bet threshold to use for Anatomy images: (select 0 if you dont know): ');
    if Anatomy_BET_thresh<=0.01||Anatomy_BET_thresh>=0.99
    % Run BET from terminal and select the desired threshold
    for thresh=0.3:0.1:0.7
        [sys,~]=system(['/usr/local/fsl/bin/bet ',Anatomy_image,'.nii.gz ',Anatomy_image,'_',num2str(thresh),'_brain.nii.gz -f ',num2str(thresh)]);
    end
    [sys,~]=system(['/usr/local/fsl/bin/fslview ',Anatomy_image,'*.nii.gz &']);
        Anatomy_BET_thresh=input('\nSelect the bet threshold to use for Anatomy images: (select 0 if you dont know): ')
        [sys,~]=system(['rm ',Anatomy_image,'*_brain.nii.gz']);
        [sys,~]=system(['/usr/local/fsl/bin/bet ',Anatomy_image,'.nii.gz ',Anatomy_image,'_brain.nii.gz -f ',num2str(thresh)]);
    end
    
    
   
%}