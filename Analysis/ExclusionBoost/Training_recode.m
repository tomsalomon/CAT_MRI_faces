
function [subject_data]=Training_recode (subj_id_num,outpath,prefix)
% _______________________________________________________________________
% ***************************** Probe Recode *****************************
% ********************* Written By: Tom Salomon, 2015 ********************
% ________________________________________________________________________
%
% This function finds all the training files of the subject with the input
% code. It then concatenates these file into one matrix, which it outputs.
% Note: since matrices can only contain data of the same type, if the
% stimuli names are non-numerical (e.g. "101.jpg"), the output matrix will
% simply fill the columns with zeroes.


% find the output directory, assuming you are working from within the
% Analysis folder
if nargin<3
    prefix=''
end

if nargin<2
outpath='./../Output/';
end
    
logs=dir([outpath,prefix '*',num2str(subj_id_num),'_training_run*.txt']) ;
subject_data=[];
for datafile = 1:length(logs)
    fid=fopen(strcat(outpath,logs(datafile).name));
    Data=textscan(fid, '%s%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f' , 'HeaderLines', 1);     %read in probe output file into P ;
    

    % Convert all string variables into numbers
    Data{1}(:)={subj_id_num}; %subject's code
    Data{1}=cell2mat(Data{1});
    
    % convert stimuli names into numbers
    image_ending=Data{4}{1}(find(Data{4}{1}=='.'):end);
    [~,stimuls_name_is_numeric] = str2num(Data{4}{1}(1:end-length(image_ending)));
    % if the stimuli have numeric name, remove the '.xxx' ending
    if stimuls_name_is_numeric
        for i=1:length(Data{1})
            Data{4}{i}=str2num(Data{4}{i}(1:end-length(image_ending)));
        end
        
        % if the stimuli do not have numeric names, replace the columns with 0's
    else
        Data{4}={zeros(length(Data{4}),1)};
    end
    Data{4}=cell2mat(Data{4});
    
    fclose(fid);
    subject_data(end+1:end+length(Data{1}),:)=cell2mat(Data);
end % end of looping through probe files
end % end of function
