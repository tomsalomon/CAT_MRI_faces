clear;
Subjects=1:49; % select subjects to be motion corrected
data_path='/export/home/DATA/schonberglab/MRI_faces/MRI/';

% timestamp
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];
fid = fopen(['text_commands/text_2_bet_BOLD_',timestamp,'.txt'] ,'a');


for sub=Subjects
    if sub<10
        sub_name=['sub00',num2str(sub)];
    else
        sub_name=['sub0',num2str(sub)];
    end
    
    bold_dir_path=[data_path,sub_name,'/BOLD/'];
    bold_dirs=dir(bold_dir_path); % find all BOLD files
    bold_dirs(1:2)=[]; % remove . ..
    for file_ind=1:length(bold_dirs)
        current_path=[bold_dir_path,bold_dirs(file_ind).name,'/'];

        boldfilename='bold_mcf.nii.gz';
        boldfilename_short=boldfilename(1:-1+min(strfind(boldfilename,'.'))); % name without .nii.gz end
        %check if there is already a mcf.nii file in the BOLD folder
        check_if_processed=length(dir([current_path,boldfilename_short,'*brain.nii.gz']));
        if check_if_processed==0
            fprintf(fid,['bet ',current_path,boldfilename,' ',current_path,boldfilename_short,'_brain.nii.gz -R -F -f 0.3\n']);
        end
    end

end
fid=fclose(fid);

