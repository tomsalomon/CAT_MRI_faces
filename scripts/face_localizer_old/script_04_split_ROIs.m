% This script can be used to split connected ROIs using k-means
% used for FFA and OFA split

clear;
close all;

% Define the following variables
ROI_anat_path = [pwd,'/Anatomical_ROI/'];
subjects = 17;

ROI = dir([ROI_anat_path,'*.nii.gz']);
num_ROIs = length(ROI);
ROI_names=strrep({ROI.name},'probability_mask_','');
ROI_names=strrep(ROI_names,'.nii.gz','');
ROI_anat = cell(num_ROIs,1);
ROI_anat_mask = ROI_anat;
ROI_center = zeros(num_ROIs,3);
for ROI_i = 1:num_ROIs
    ROI_anat{ROI_i}=niftiread([ROI(ROI_i).folder,'/',ROI(ROI_i).name]);
    ROI_anat_mask{ROI_i}=ROI_anat{ROI_i}>0.1;
    non_0_voxels=find(ROI_anat{ROI_i});
    % Use the x y z coordinates as clustering features;
    voxels_coordinates=zeros(length(non_0_voxels),3);
    for i =1:length(non_0_voxels)
        [voxels_coordinates(i,1),voxels_coordinates(i,2),voxels_coordinates(i,3)]=ind2sub(size(ROI_anat{ROI_i}),non_0_voxels(i));
    end
    ROI_center(ROI_i,:)= mean(voxels_coordinates);
end

cluster_table_options=dir([pwd,'/cluster_table*.txt']);
change_logs = contains({cluster_table_options.name},'changes_log');
cluster_table_options(change_logs)=[]; %remove changes logs from the options
% use the latest cluster table available
cluster_table = readtable([pwd,'/',cluster_table_options(end).name],'delimiter','\t');
cluster_mat = table2array(cluster_table); % sometimes its more conveinvient to work with mats
cluster_mat(cluster_mat==0) = nan;

time = clock;
timestamp = sprintf('%i%02i%02i_%02i_%02i',time(1),time(2),time(3),time(4),time(5));
fid = fopen(['cluster_table_changes_log_',timestamp,'.txt'],'w');
fprintf(fid,'Subject\tROI_index\tROI_name\told_cluster\tnew_cluster\n');

h = waitbar(0,'Analyzing...');
for subject = subjects
    waitbar(find(subject==subjects)/length(subjects),h,sprintf('Splitting clusters for subject %i out of %i',find(subject==subjects),length(subjects)))
    selected_clusters = cluster_mat(subject,:);
    changes = selected_clusters;
    num_cluster_appearances = sum(selected_clusters==selected_clusters');
    if max(num_cluster_appearances)>1 % in case there are non uniue clusters
        sub_name =  sprintf('sub-%03i',subject);
        sub_path = [pwd,'/Functional_ROI/',sub_name,'/'];
        clusters_to_split = unique(selected_clusters(num_cluster_appearances>1));
        for cluster_code = clusters_to_split
            ROIs_to_split_to = find(selected_clusters==cluster_code);
            num_ROIs_to_split_to = length(ROIs_to_split_to);
            mask = zeros (size(ROI_anat_mask{1}));
            for ROI_i = ROIs_to_split_to
                mask = mask + ROI_anat_mask{ROI_i};
            end
            mask = mask>0;
            
            cluster_path=sprintf('%scluster_%03i.nii.gz',sub_path,cluster_code);
            
            info = niftiinfo(cluster_path);
            origin_img=niftiread(cluster_path).*mask;
            non_0_voxels=find(origin_img==1);
            % Use the x y z coordinates as clustering features;
            voxels_coordinates=zeros(length(non_0_voxels),3);
            for i =1:length(non_0_voxels)
                [voxels_coordinates(i,1),voxels_coordinates(i,2),voxels_coordinates(i,3)]=ind2sub(size(origin_img),non_0_voxels(i));
            end
            rng(1); % for reproducibility
            voxels_kmeans=kmeans(voxels_coordinates,num_ROIs_to_split_to,'Replicates',10);
            origin_kmeans=origin_img;
            origin_kmeans(origin_img==1)=voxels_kmeans;
            output_ROI=cell(num_ROIs_to_split_to,1);
            match = zeros(num_ROIs_to_split_to);
            for k = 1:num_ROIs_to_split_to
                output_ROI{k} = origin_kmeans == k;
                for ROI_i = 1:num_ROIs_to_split_to
                    match(k,ROI_i) = sum(output_ROI{k}(:).*ROI_anat{ROIs_to_split_to(ROI_i)}(:))/sum(output_ROI{k}(:));
                end
            end
            [best_combination,best_combination_score] = find_best_match (match,0);
            
            num_existig_clusters=length(dir([sub_path,'cluster_0*']));
            for k = 1:num_ROIs_to_split_to
                new_cluster_code = num_existig_clusters + k;
                new_cluster_path=sprintf('%scluster_%03i_split',sub_path,new_cluster_code);
                niftiwrite(single(output_ROI{k}),new_cluster_path,info,'Compressed',1);
                ROI_ind = ROIs_to_split_to(best_combination==k);
                ROI_path = sprintf('%sROI_%02i_%s.nii.gz',sub_path,ROI_ind,ROI_names{ROI_ind});
                delete(ROI_path);
                copyfile([new_cluster_path,'.nii.gz'],ROI_path)
                changes(ROI_ind) = new_cluster_code;
                fprintf(fid,'%s\t%i\t%s\t%i\t%i\n',sub_name,ROI_ind,ROI_names{ROI_ind},cluster_code,new_cluster_code);
                
            end
        end
        cluster_table(subject,:) = array2table(changes);
    end
end
close(h)
fid=fclose(fid);
writetable(cluster_table,['cluster_table_',timestamp,'.txt'],'Delimiter','\t')

