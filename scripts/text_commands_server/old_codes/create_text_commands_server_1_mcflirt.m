Subjects=1:49; % select subjects to be motion corrected

% timestamp
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];
fid = fopen(['text_commands/text_1_mcflirt_',timestamp,'.txt'] ,'a');

data_path='/export/home/DATA/schonberglab/MRI_faces/MRI/';

for sub=Subjects
    if sub<10
        sub_name=['sub00',num2str(sub)];
    else
        sub_name=['sub0',num2str(sub)];
    end
    
    BOLD_dir_path=[data_path,sub_name,'/BOLD/'];
    bold_dirs=dir(BOLD_dir_path); % find all BOLD Directories
    bold_dirs(1:2)=[]; % remove . ..
    for bold_ind=1:length(bold_dirs)
        current_path=[BOLD_dir_path,bold_dirs(bold_ind).name,'/'];
        boldfilename='bold.nii.gz';
        boldfilename_short=boldfilename(1:-1+min(strfind(boldfilename,'.'))); % name without .nii.gz end
        %check if there is already a mcf.nii file in the BOLD folder
        check_is_there_mcf=length(dir([current_path,boldfilename_short,'*mcf.nii.gz']));
        if check_is_there_mcf==0
            fprintf(fid,['mcflirt -in ',current_path,boldfilename,' -plots -report\n']);
        end
    end

end
fid=fclose(fid);