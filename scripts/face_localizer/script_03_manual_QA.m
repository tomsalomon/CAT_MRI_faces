% This code is used to go over all participants, make sure you like the ROI
% assignment and track down change

clear;
close all;

% create environment in order to be able to run FSL from Matlab
setenv('FSLDIR','/share/apps/fsl/'); %the FSL folder
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %the output type
setenv('PATH', [getenv('PATH') ':/share/apps/fsl/bin']);

% Define the following variables
%subjects = 1:50;
subjects = [17];
ROI_anat_path = [pwd,'/Anatomical_ROI/'];

ROI = dir([ROI_anat_path,'*.nii.gz']);
num_ROIs = length(ROI);
ROI_names=strrep({ROI.name},'probability_mask_','');
ROI_names=strrep(ROI_names,'.nii.gz','');

cluster_table_options=dir([pwd,'/cluster_table*.txt']);
change_logs = contains({cluster_table_options.name},'changes_log');
cluster_table_options(change_logs)=[]; %remove changes logs from the options
% use the latest cluster table available
cluster_table = readtable([pwd,'/',cluster_table_options(end).name],'delimiter','\t');

ROI_center_mass = cell(num_ROIs,1);
for ROI_i = 1:num_ROIs
    [~,ROI_center_mass{ROI_i}]=system_numeric_output(sprintf('fslstats %s/%s -c',ROI(ROI_i).folder,ROI(ROI_i).name));
    ROI_center_mass{ROI_i}(4)=[];
    ROI_center_mass{ROI_i}=round(ROI_center_mass{ROI_i},0);
end

dlg_title = 'Manual QA';
dlg_prompt = ROI_names;
dlg_prompt{1} = sprintf(...
    ['Please validate the automatically selected cluster for each ROIs.\n'...
    'Select 0 if no valid option is available.\n\n%s'],ROI_names{1});
dlg_dims = [1 40];
time = clock;
timestamp = sprintf('%i%02i%02i_%02i_%02i',time(1),time(2),time(3),time(4),time(5));

fid = fopen(['cluster_table_changes_log_',timestamp,'.txt'],'w');
fprintf(fid,'Subject\tROI_index\tROI_name\told_cluster\tnew_cluster\n');
for subject = subjects
    sub_name =  sprintf('sub-%03i',subject);
    sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
    
    
    %     visualization_str = ['fsleyes /share/apps/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz ',sub_path,'cluster_valid_mask.nii.gz -cm hsv ',sub_path,'ROI*.nii.gz &'];
    visualization_str=cell(num_ROIs,1);
    for ROI_ind = 1:num_ROIs
        world_location = sprintf('%i %i %i',ROI_center_mass{ROI_ind});
        if cluster_table{subject,ROI_ind} > 0
            ROI_path = [sub_path,'ROI*',ROI_names{ROI_ind},'*.nii.gz '];
        else
            ROI_path = '';
        end
        visualization_str{ROI_ind} = ['fsleyes -wl ',world_location,' /share/apps/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz ',sub_path,'cluster_valid_mask.nii.gz -cm hsv -n available_clusters_find_',ROI_names{ROI_ind},' ',ROI_path,' & '];
    end
    visualization_str=strjoin(flip(visualization_str));
    visualize_fsleyes = questdlg (['Plesae help validate the location of the ROIs for ',sub_name,'. Do you want to visualize with system or copy to clipboard?'], ['Validate',sub_name], 'system', 'clipboard', 'clipboard');
    if strcmp(visualize_fsleyes,'system')
        system(visualization_str);
    else
        clipboard('copy',visualization_str);
    end
    
    dlg_defualt_input = split(num2str(table2array(cluster_table(subject,:))));
    answer = inputdlg(dlg_prompt,dlg_title,dlg_dims,dlg_defualt_input');
    if isempty(answer)
        break
    end
    changed_ROIs = ~strcmp(dlg_defualt_input,answer);
    if sum(changed_ROIs)>0
        changed_ROI_locations = find(changed_ROIs);
        cluster_table(subject,:) = array2table(cellfun(@str2double,answer)');
        for ROI_ind = changed_ROI_locations'
            % fprintf(fid,'Subject\tROI_index\tROI_name\told_cluster\tnew_cluster\n');
            fprintf(fid,'%s\t%i\t%s\t%s\t%s\n',sub_name,ROI_ind,ROI_names{ROI_ind},dlg_defualt_input{ROI_ind},answer{ROI_ind});
            ROI_path = sprintf('%sROI_%02i_%s.nii.gz',sub_path,ROI_ind,ROI_names{ROI_ind});
            try
                delete(ROI_path);
            catch
            end
            try
                
                rmdir(ROI_path);
            catch
            end
            if cluster_table{subject,ROI_ind} > 0
                cluster_path = sprintf('%scluster_%03i*.nii.gz',sub_path,cluster_table{subject,ROI_ind});
                copyfile(cluster_path,ROI_path)
            end
        end
    end
end
writetable(cluster_table,['cluster_table_',timestamp,'.txt'],'Delimiter','\t')

fid=fclose(fid);