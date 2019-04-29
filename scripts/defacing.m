setenv('PATH', [getenv('PATH') ':/python/anaconda3.44-python36']);
system('module load python/anaconda3.44-python36')

data_path = '/export2/DATA/NoBackup/MRI_faces_openNeuro/';
subs = 1:50;

number_cores = 26;

% initiate parallel computing
test_pool_open = gcp('nocreate');
if isempty(test_pool_open)
    parpool(number_cores)
end

parfor_progress (length(subs))
parfor sub_i = subs
    for ses_i = 1:2
        file = dir(sprintf('%ssub-%03i/ses-%02i/anat/*.nii.gz',data_path,sub_i,ses_i));
        if numel(file) ~=1 % skip non existing session 2
            continue
        end
        original_file = [file.folder,'/',file.name];
        ok = system(['pydeface ',original_file]);
        if ok == 0 
        defaced_file = [original_file(1:end-7),'_defaced.nii.gz'];
        delete(original_file)
        movefile(defaced_file,original_file)
        end
            
    end
    parfor_progress();
end
parfor_progress(0);
