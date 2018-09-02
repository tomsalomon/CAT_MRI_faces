
Subjects = 1:50;
ses_num='01';

tsv_main_path= './../';
onsets_main_path = './../model/';

for sub = Subjects    
    if sub<10
        sub_name=['sub-00',num2str(sub)];
    else
        sub_name=['sub-0',num2str(sub)];
    end
    tsv_sub_path=[tsv_main_path,sub_name,'/ses-',ses_num,'/func/'];
    onsets_sub_path=[onsets_main_path,sub_name,'/model/model001/onsets/'];
    
    events_files=dir([tsv_sub_path,'*events.tsv']);
    for file_num=1:length(events_files)
        file_name=events_files(file_num).name;
        file_name_short=file_name(1:end-10);
        tsv_data=struct2table(tdfread([tsv_sub_path,file_name]));
        
        for regressor = 1:max(tsv_data.regressor)+1 % +1 because of missed trials (22) regressor in prob
            regressor_filename=[file_name_short,'cond-',num2str(regressor,'%02i'),'.txt'];
            regressor_array=table2array(tsv_data(tsv_data.regressor==regressor,1:3));
            if isempty(regressor_array)
                regressor_array=[0,0,0];
            end
            dlmwrite([onsets_sub_path,regressor_filename],regressor_array,'delimiter','\t');
        end
    end
end

