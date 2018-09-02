
% might need to run this first: module load opt-python

Subjects=1:49; % select subjects to be motion corrected
data_path='/export/home/DATA/schonberglab/MRI_faces/MRI/';
fmriqa_path='/export/home/DATA/schonberglab/MRI_faces/fmriqa-master/';

% timestamp
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];
fid = fopen(['text_commands/text_3_QA_',timestamp,'.txt'] ,'a');



for sub=Subjects
    if sub<10
        sub_name=['sub00',num2str(sub)];
    else
        sub_name=['sub0',num2str(sub)];
    end

    BOLD_dirs=dir([data_path,sub_name,'/BOLD/task*']); % find all BOLD Directories
    % for all BOLD files to BET
    for j=1:length(BOLD_dirs)
        BOLD_dir=[data_path,sub_name,'/BOLD/',BOLD_dirs(j).name];
        %check if there is already a brain.nii file in the BOLD folder
        check_is_there_QA=length(dir([BOLD_dir,'/QA*']));
        if check_is_there_QA==0
            fprintf(fid,['python ',fmriqa_path,'fmriqa.py ',BOLD_dir,'/bold_mcf.nii.gz 2\n']);        
        end
    end
end
fid=fclose(fid);




% clear 
% close all
% 
% Subjects=33:44; % select subjects to be motion corrected
% 
% curr_dir=pwd;
% % these are the bet default values - change  if you wish
% total_num_of_QA=0; % hoe many images need QA
% QA_completed=0;
% 
% % timestamp
% c = clock;
% hr = sprintf('%02d', c(4));
% minutes = sprintf('%02d', c(5));
% timestamp = [date,'_',hr,'h',minutes,'m'];
% 
% fid = fopen(['text_commands_server_QA_',timestamp,'.txt'] ,'a');
% 
% 
% % loop over files - and do QA
% 
% for i=1:length(Subjects)
%     if Subjects(i)<10
%         sub_name=['sub00',num2str(Subjects(i))];
%     else
%         sub_name=['sub0',num2str(Subjects(i))];
%     end
% 
%     BOLD_dirs=dir(['./MRI/',sub_name,'/BOLD/task*']); % find all BOLD Directories
%     % for all BOLD files to BET
%     for j=1:length(BOLD_dirs)
%         BOLD_dir=[pwd,'/MRI/',sub_name,'/BOLD/',BOLD_dirs(j).name];
%         %check if there is already a brain.nii file in the BOLD folder
%         check_is_there_QA=length(dir([BOLD_dir,'/QA*']));
%         if check_is_there_QA==0
%             fprintf(fid,['python ',curr_dir,'/fmriqa-master/fmriqa.py ',BOLD_dir,'/bold_mcf.nii.gz 2\n']);        
%         end
%     end
%     
% end
% 
% fclose(fid);
