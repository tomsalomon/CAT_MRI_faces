
function [subject_data]=Probe_recode_followup (subj_id_num,outpath)
% _______________________________________________________________________
% ***************************** Probe Recode *****************************
% ********************* Written By: Tom Salomon, 2015 ********************
% ________________________________________________________________________
%
% This function finds all the probe files of the subject with the input
% code. It then concatenates these file into one matrix, which it outputs.
% Note: since matrices can only contain data of the same type, if the
% stimuli names are non-numerical (e.g. "101.jpg"), the output matrix will
% simply fill the "image left" and "image right" columns with zeroes.


% find the output directory, assuming you are working from within the
% Analysis folder
if nargin<2
outpath='./../Output/followup/';
end

logs=dir([outpath,'/*',num2str(subj_id_num),'_probe_block*.txt']) ;
subject_data=[];
for datafile = 1:length(logs)
    fid=fopen(strcat(outpath,logs(datafile).name));
    Data=textscan(fid, '%s%f%f%f%f%f%f%s%s%f%f%f%s%f%f%f%f%f%f' , 'HeaderLines', 1);     %read in probe output file into P ;
    
    % Convert all string variables into numbers
    Data{1}(:)={subj_id_num}; %subject's code
    
    
    % convert stimuli names into numbers
    image_ending=Data{8}{1}(find(Data{8}{1}=='.'):end);
    [~,stimuls_name_is_numeric] = str2num(Data{8}{1}(1:end-length(image_ending)));
    % if the stimuli have numeric name, remove the '.xxx' ending
    if stimuls_name_is_numeric
        for i=1:length(Data{1})
            Data{8}{i}=str2num(Data{8}{i}(1:end-length(image_ending))); % left stimulus
            Data{9}{i}=str2num(Data{9}{i}(1:end-length(image_ending))); % right stimulus
        end
        
        % if the stimuli do not have numeric names, replace the columns with 0's
    else
        Data{8}={zeros(length(Data{8}),1)}; % left stimulus
        Data{9}={zeros(length(Data{9}),1)}; % right stimulus
    end
    
    Data{13}(strcmp(Data{13},'b'))={1}; % response: 1 for left
    Data{13}(strcmp(Data{13},'y'))={0}; % response: 0 for right
    Data{13}(strcmp(Data{13},'x'))={999}; % response: 999 for no response
    
    Data{1}=cell2mat(Data{1});
    Data{8}=cell2mat(Data{8});
    Data{9}=cell2mat(Data{9});
    Data{13}=cell2mat(Data{13});
    
    fclose(fid);
    subject_data(end+1:end+length(Data{1}),:)=cell2mat(Data);
end % end of looping through probe files
end % end of function
