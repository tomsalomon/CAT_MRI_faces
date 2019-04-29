
clear;

mainpath = './..';
output_path = '/export2/DATA/NoBackup/MRI_faces_openNeuro' ;
task_names = {'responsetostim','training','probe','localizer'};

cope_task1 = {'HV Go','HV NoGo','LV Go','LV NoGo','HV Neutral','LV Neutral','HV Sanity','LV Sanity','HV Go - by choice','HV NoGo - by choice','LV Go - by choice','LV NoGo - by choice','All - by value'};
cope_task2 = {'HV Go','HV Go - by choice','HV Go - by value','HV Go - by GSD','LV Go','LV Go - by choice','LV Go - by value','LV Go - by GSD','HV NoGo','HV NoGo - by choice','HV NoGo - by value','LV NoGo','LV NoGo - by choice','LV NoGo - by value','Go - missed','NoGo - erroneous response','NoGo - Sanity and fillers','All Go - by RT'};
cope_task3 = {'HV Go','HV Go - by choice','HV Go - by value diff','HV NoGo','HV NoGo - by choice','HV NoGo - by value diff','HV - by RT','LV Go','LV Go - by choice','LV Go - by value diff','LV NoGo','LV NoGo - by choice','LV NoGo - by value diff','LV - by RT','Sanity','Missed trials'};
cope_task4 = {'faces','objects'};

h = waitbar(0,'writing events.tsv files');
for sub = 1:50
    sub_name = sprintf('sub-%03i',sub);
    for ses_i = 1:2
        ses_name = sprintf('ses-%02i',ses_i);
        sub_outpath = sprintf('%s/%s/%s/func',output_path,sub_name,ses_name);
        onsets_mainpath = sprintf('%s/%s/%s/model/model001/onsets/',...
            mainpath,sub_name,ses_name);
        scans = dir([onsets_mainpath,'/task*']);
        if isempty(scans)
            continue;
        end
        for scan_i = 1:numel(scans)
            scan_name = scans(scan_i).name;
            scan_name_split = strsplit(scan_name,{'-','_'});
            task_i = find(contains(task_names,scan_name_split{2}));
            switch task_i
                case 1
                    cope_names = cope_task1;
                case 2
                    cope_names = cope_task2;
                case 3
                    cope_names = cope_task3;
                case 4
                    cope_names = cope_task4;
            end
            num_conds = numel(cope_names);
            events_mat = nan(1,4);
            for cond_i = 1: num_conds
                cond_file = sprintf('%s/%s/cond%03i.txt',onsets_mainpath,scans(scan_i).name,cond_i);
                events_mat_tmp = load(cond_file);
                events_mat_tmp(:,4) = cond_i;
                events_mat = [events_mat;events_mat_tmp];
            end
            events_mat(1,:)=[];
            events_table = array2table(events_mat,'VariableNames',{'onset','duration','parametric_modulation','regressor'});
            events_table.description = cope_names(events_table.regressor)';
            events_table_filepath = sprintf('%s/%s_%s_%s_events.tsv',...
                sub_outpath,sub_name,ses_name,scan_name);
            writetable(events_table,events_table_filepath,'Delimiter','\t','FileType','text');
        end
    end
    waitbar(sub/50,h)
end
close(h)