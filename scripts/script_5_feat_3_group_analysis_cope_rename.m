
clear;

% Define these variables
ses_num=1; % Session number
task_num=1;
z_thresh=2.3; % 2.3, 3.1
SVC = 1; % change to true to perform small volume correction
SVC_ROI_num = 4; % define the SVC ROI: '01_vmPFC','02_hippocampus','03_SPL','04_striatum'

SVC_ROI_names = {'01_vmPFC','02_hippocampus','03_SPL','04_striatum'};
if SVC
    SVC_ROI_name=SVC_ROI_names{SVC_ROI_num};
else
    SVC_ROI_name=''; % in case you don't want SVC, remove the mask
end

if ses_num ==1
    Subjects=[2,4:14,16:17,19:25,27:41,43:44,46:49];
elseif ses_num ==2
    Subjects=[2,4:5,8,10:12,14,17,20:23,27,29:31,33:36,38:40,44];
end


ses_name=['ses-0',num2str(ses_num)];
designs_template_dir= ['./../models/model001/',ses_name,'/designs/'];
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
        num_of_copes=27;
        contrast_name={'HV Go';'HV NoGo';'LV Go';'LV NoGo';'HV Neutral';'LV Neutral';'HV Sanity';'LV Sanity';'HV Go - Mod';'HV NoGo - Mod';'LV Go - Mod';'LV NoGo - Mod';'All - Mod by value';'All HV';'All LV';'HV minus LV';'All Go minus NoGo';'HV Go minus NoGo';'LV Go minus NoGo';'All Go minus NoGo - Mod';'HV Go minus NoGo - Mod';'LV Go minus NoGo - Mod';'All Go';'All Go - Mod';'All NoGo';'All NoGo - Mod';'All NoGo - with Neutral and Sanity'};
    case 2
        num_of_copes=25;
        contrast_name={'HV Go';'HV Go - by choice';'HV Go - by value';'HV Go - by GSD';'LV Go';'LV Go - by choice';'LV Go - by value';'LV Go - by GSD';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by value';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by value';'Go - missed';'NoGo - erroneous response';'NoGo - Sanity and fillers';'All Go - by RT';'HV Go > NoGo';'LV Go > NoGo';'All Go > NoGo';'All Go';'All NoGo';'All Go - by choice';'All NoGo - by choice';};
    case 3
        num_of_copes=26;
        contrast_name={'HV Go';'HV Go - by choice';'HV Go - by WTP diff';'HV NoGo';'HV NoGo - by choice';'HV NoGo - by WTP diff';'HV - by RT';'LV Go';'LV Go - by choice';'LV Go - by WTP diff';'LV NoGo';'LV NoGo - by choice';'LV NoGo - by WTP diff';'LV - by RT';'Sanity';'Missed trials';'HV chose Go > chose NoGo';'HV - chose Go > Chose NoGo - mod by choice';'LV - chose Go > Chose NoGo';'LV - chose Go >chose NoGo - mod by choice';'all - chose go > chose NoGo';'All - chose Go > Chose NoGo - mod by choice';'All Go';'All NoGo';'All Go modulated';'All NoGo Modulated'};
    case 4
        num_of_copes=[];
        contrast_name={ };
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
for i=1:length(Subjects)
    probe_data=Probe_analysis(Subjects(i),behave_data_path);
    prop_chose_Go(i,:)=[probe_data(7),probe_data(8),mean(probe_data(7:8))];
end
% modulation matrix: rows = sub, cols = cope
probe_mudulation=prop_chose_Go(:,1)*is_HV_contrast'+prop_chose_Go(:,2)*is_LV_contrast'+prop_chose_Go(:,3)*is_All_contrast';
probe_mudulation_demeaned=detrend(probe_mudulation,'constant');

for cope=1:num_of_copes
    cope_name=sprintf('cope%i',cope);
    design_output=['design_group_',task_name,'_',cope_name,'.fsf'];
    
    if strcmp(design_template,design_output)
        continue
    end
    
    fin = fopen([designs_template_dir,design_template]);
    fout = fopen([designs_template_dir,design_output],'w');
    
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
        for sub=1:length(Subjects)
            s = strrep(s,sprintf('set fmri(evg%i.2) 0',sub),sprintf('set fmri(evg%i.2) %.4f',sub,probe_mudulation_demeaned(sub,cope)));
        end
        fprintf(fout,'%s\n',s);
    end
    fin=fclose(fin);
    fout=fclose(fout);
end % end of sub

