
clear;

% Define these variables
ses_num=1; % Session number
task_num=3;
z_thresh=2.3; % 2.3, 3.1
SVC = 0; % change to true to perform small volume correction
SVC_ROI_num = 1; % define the SVC ROI: '01_vmPFC','02_hippocampus','03_SPL','04_striatum'
models = 2:7; % 1 - GLM, 2:7 - PPI
main_path = [pwd,'/..'];
SVC_ROI_names = {'01_vmPFC','02_hippocampus','03_SPL','04_striatum'};
if SVC
    SVC_ROI_name=SVC_ROI_names{SVC_ROI_num};
else
    SVC_ROI_name=''; % in case you don't want SVC, remove the mask
end

if ses_num ==1
    if task_num <= 2
        Subjects=[2,4:14,16:17,19:25,27:41,43:44,46:49];
    else
        Subjects=[2,4:14,16:17,19:25,27:41,43:49];
    end
elseif ses_num ==2
    Subjects=[2,4:5,8,10:12,14,17,20:23,27,29:31,33:36,38:40,44];
end

progress = 0;
h = waitbar(progress,'Creating design fsf files');
model_name = sprintf('model%03i',models(1));
ses_name=['ses-0',num2str(ses_num)];
designs_template_dir= ['./../models/',model_name,'/',ses_name,'/designs/'];

for model = models
    model_name = sprintf('model%03i',model);
    designs_dir= ['./../models/',model_name,'/',ses_name,'/designs/'];
    task_names={'task-responsetostim','task-training','task-probe','task-localizer'};
    task_name=task_names{task_num};
    design_template=['design_group_',task_name,'_template.fsf'];
    if SVC
        z_thresh_string='SVC';
    else
        z_thresh_string=strrep(num2str(z_thresh),'.','_');
    end
    
    
    behave_data_path_ses1 = './../behavioral_data/';
    if ses_num==1
        behave_data_path = behave_data_path_ses1;
    else
        behave_data_path = [behave_data_path_ses1,'ses-02/'];
    end
    c=clock;
    CurrentDate=sprintf('%i_%02.f_%02.f',c(1),c(2),c(3));
    
    switch task_num
        case 1
            %             num_of_copes=27;
            %             contrast_name={'HV Go';'HV NoGo';'LV Go';'LV NoGo';'HV Neutral';'LV Neutral';'HV Sanity';'LV Sanity';'HV Go - Mod';'HV NoGo - Mod';'LV Go - Mod';'LV NoGo - Mod';'All - Mod by value';'All HV';'All LV';'HV minus LV';'All Go minus NoGo';'HV Go minus NoGo';'LV Go minus NoGo';'All Go minus NoGo - Mod';'HV Go minus NoGo - Mod';'LV Go minus NoGo - Mod';'All Go';'All Go - Mod';'All NoGo';'All NoGo - Mod';'All NoGo - with Neutral and Sanity'};
        case 2
            num_of_copes=4;
            contrast_name={'PPI - All Go > NoGo';'PPI - seed';'PPI - All Go';'PPI - All NoGo'};
        case 3
            %             num_of_copes=26;
            %             contrast_name={'HV Go';'HV Go - by choice';'HV Go - by WTP diff';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by WTP diff';'HV - by RT';'LV Go';'LV Go - by choice';'LV Go - by WTP diff';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by WTP diff';'LV - by RT';'Sanity';'Missed trials';'HV chose Go > chose NoGo';'HV - chose Go > Chose NoGo - mod by choice';'LV - chose Go > Chose NoGo';'LV - chose Go >chose NoGo - mod by choice';'all - chose go > chose NoGo';'All - chose Go > Chose NoGo - mod by choice';'All Go';'All NoGo';'All Go modulated';'All NoGo Modulated'};
        case 4
            %             num_of_copes=[];
            %             contrast_name={ };
    end
    
    [is_HV_contrast,is_LV_contrast,is_All_contrast,is_Sanity_contrast,...
        is_Neutral_contrast]=deal(false(size(contrast_name)));
    
    for i=1:length(contrast_name)
        is_HV_contrast(i)=~isempty(regexpi(contrast_name{i},'HV'));
        is_LV_contrast(i)=~isempty(regexpi(contrast_name{i},'LV'));
        is_All_contrast(i)=~isempty(regexpi(contrast_name{i},'All'));
        is_Sanity_contrast(i)=~isempty(regexpi(contrast_name{i},'sanity'));
        is_Neutral_contrast(i)=~isempty(regexpi(contrast_name{i},'Neutral'));
    end
    is_neither_HV_nor_LV_contrast=is_Sanity_contrast|(is_HV_contrast&is_LV_contrast)|(is_All_contrast&is_LV_contrast)|(is_All_contrast&is_HV_contrast)|is_Neutral_contrast;
    is_HV_contrast(is_neither_HV_nor_LV_contrast)=false;
    is_LV_contrast(is_neither_HV_nor_LV_contrast)=false;
    
    if sum(is_HV_contrast.*is_LV_contrast.*is_All_contrast)~=0
        warning(['Overlap between contrast. Contrasts were not defined correctly. ',...
            'Please fix this issue before running the group analysis'])
    end
    % modulation as proportions Go items were chosen: HV, LV, Means
    prop_chose_Go=zeros(length(Subjects),3);
    subject_is_in_model = true(length(Subjects),1);
    feat_path = cell(length(Subjects),1);
    for i=1:length(Subjects)
        probe_data=Probe_analysis(Subjects(i),behave_data_path);
        prop_chose_Go(i,:)=[probe_data(7),probe_data(8),mean(probe_data(7:8))];
        sub_name = sprintf('sub-%03i',Subjects(i));
        feat_path{i} = dir([main_path,'/',sub_name,'/',ses_name,'/model/',model_name,'/*',task_name,'.gfeat']);
        subject_is_in_model(i) = ~isempty(feat_path{i});
        if subject_is_in_model(i)
        feat_path{i} = [feat_path{i}.folder,'/',feat_path{i}.name];
        end
    end
    % modulation matrix: rows = sub, cols = cope
    probe_mudulation=prop_chose_Go(:,3);
    probe_mudulation(~subject_is_in_model,:) = []; % replace not included participants with nan
    feat_path(~subject_is_in_model,:) = [];
    probe_mudulation_demeaned=detrend(probe_mudulation,'constant');
    new_n = sum(subject_is_in_model);
    new_subjects = Subjects(subject_is_in_model);
    
    for cope=1:num_of_copes
        cope_name=sprintf('cope%i',cope);
        design_output=['design_group_',task_name,'_',cope_name,'.fsf'];
        
        if strcmp(design_template,design_output)
            continue
        end
        
        fin = fopen([designs_template_dir,design_template]);
        fout = fopen([designs_dir,design_output],'w');
        
        replace_CurrentDate = sprintf('%s_Zthresh_%s',CurrentDate,z_thresh_string);
        if SVC
            replace_CurrentDate = sprintf('%s_%s_%s',z_thresh_string,SVC_ROI_name,CurrentDate);
        end
        
        while ~feof(fin)
            s = fgetl(fin);
            s = strrep(s, 'cope1', cope_name);
            s = strrep(s,contrast_name{1},contrast_name{cope});
            s = strrep(s,SVC_ROI_names{1},SVC_ROI_name);
            s = strrep(s,'CurrentDate',replace_CurrentDate);
            s = strrep(s,'set fmri(z_thresh) 3.1',sprintf('set fmri(z_thresh) %.1f',z_thresh));
            s = strrep(s,'model002',model_name);
            for sub=1:new_n
                s = strrep(s,sprintf('set fmri(evg%i.2) 0',sub),sprintf('set fmri(evg%i.2) %.4f',sub,probe_mudulation_demeaned(sub)));
                if contains(s,sprintf('set feat_files(%i)',sub))
                    s = sprintf('set feat_files(%i) %s/%s.feat',sub,feat_path{sub},cope_name);
                end
            end
            if new_n < length(Subjects)
                for sub=new_n+1 : length(Subjects)
                    if contains(s,{sprintf('evg%i',sub),sprintf('groupmem.%i',sub),sprintf('feat_files(%i',sub)})
                        s='';
                    end
                end
                % change original n (e.g. 42)
                new_n_lines = {'set fmri(npts)','set fmri(multiple)'};
                if contains(s,new_n_lines) % 'set fmri(npts) 42';
                    s = sprintf('%s %i', s(1:end-3),new_n); % change n (e.g. 42)
                end
            end
            fprintf(fout,'%s\n',s);
        end
        fin=fclose(fin);
        fout=fclose(fout);
        progress = progress + 1/(numel(models)*num_of_copes);
        waitbar(progress,h)
    end % end of cope
end % end of model
close(h)

