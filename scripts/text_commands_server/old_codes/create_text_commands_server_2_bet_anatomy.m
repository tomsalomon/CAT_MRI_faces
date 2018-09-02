Subjects=40:49; % select subjects
data_path='/export/home/DATA/schonberglab/MRI_faces/MRI/';

% timestamp
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];
fid = fopen(['text_commands/text_2_bet_anatomy_',timestamp,'.txt'] ,'a');


for sub=Subjects
    if sub<10
        sub_name=['sub00',num2str(sub)];
    else
        sub_name=['sub0',num2str(sub)];
    end
    
    anat_dir_path=[data_path,sub_name,'/anatomy/'];
    % highres
    check_is_there_brain=length(dir([anat_dir_path,'highres001_brain.nii.gz']));
    if check_is_there_brain==0
        fprintf(fid,['bet ',anat_dir_path,'highres001.nii.gz ',anat_dir_path,'highres001_brain.nii.gz -f 0.4 -R\n']);
    else
        continue
    end
    
    % inplanes
    anat_files=dir([anat_dir_path,'inplane*.nii.gz']); % find all BOLD Directories
    for file_ind=1:length(anat_files)
        anatfilename=anat_files(file_ind).name;
        anatfilename_short=anatfilename(1:-1+min(strfind(anatfilename,'.'))); % name without .nii.gz end
        %check if there is already a mcf.nii file in the BOLD folder
        check_is_there_brain=length(dir([anat_dir_path,anatfilename_short,'*brain.nii.gz']));
        if check_is_there_brain==0
            fprintf(fid,['bet ',anat_dir_path,anatfilename,' ',anat_dir_path,anatfilename_short,'_brain.nii.gz -f 0.3 -R\n']);
        end
    end
    
end
fid=fclose(fid);
