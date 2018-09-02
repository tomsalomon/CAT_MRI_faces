% +~+~+~+~+~+~+~+ Written By Tom Salomon and Michal Tietler +~+~+~+~+~+~+~+
% +~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+ July 2018 +~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+
% +~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+
%
% This script is used to convert MRI faces files to unified file names
% for behavioral txt file and eyetracking asc and edf files.
% The script will add to each behavioral txt file 2 new columns indiating:
% 1. Trial onset 2. Trial duration.
% Ecah MRI scan will have identicaly named txt behavioral, edf and asc
% eye-tracker data files.
%
% Dependencies:
% -------------
% name_changer.m - define the conversion rule from the original name to the
% target file name
% validate_match.m - counts number of txt, edf and asc files to make sure
% the proportion of matching eye tracker data files to txt behavioral
% files.
%
% Data organization:
% ------------------
% All original data (session 1 + session 2) can be in the same input_path.
% converted data files will be saves in the output_path, both defined by
% the user at first.
%
% Enjoy! :)

clear;
close all;

% define these variables:
input_path = './../Output_all_files/'; % here is your raw data
output_path = './pre_processed_data/'; % here the preprocessed data will be written to
subject_numbers = [101:149,151];

%% Copy all edf files 

inputFiles = dir([input_path,'*.edf']);
inputFileNames = {inputFiles.name}';
outputFileNames = name_changer(inputFiles);
% make sure all filenames are unique
[UniqueOutputFileNames,~,X] = unique(outputFileNames(:));
Count = hist(X,unique(X));
if max(Count)>1
    non_unique_inputs = inputFileNames(contains(outputFileNames,UniqueOutputFileNames(Count>1)));
    error ([sprintf('Some Duplicate file names were found:'),sprintf('\n%s',non_unique_inputs{:})])
end

h = waitbar(0,'Copying all edf files');
for i = 1:length(inputFiles)
    copyfile([input_path,inputFiles(i).name],[output_path,outputFileNames{i}])
    waitbar(i/length(inputFiles),h)
end
close (h)

%% Copy all asc files 

inputFiles = dir([input_path,'*.asc']);
inputFileNames = {inputFiles.name}';
outputFileNames = name_changer(inputFiles);
% make sure all filenames are unique
[UniqueOutputFileNames,~,X] = unique(outputFileNames(:));
Count = hist(X,unique(X));
if max(Count)>1
    non_unique_inputs = inputFileNames(contains(outputFileNames,UniqueOutputFileNames(Count>1)));
    error ([sprintf('Some Duplicate file names were found:'),sprintf('\n%s',non_unique_inputs{:})])
end

h = waitbar(0,'Copying all asc files');
for i = 1:length(inputFiles)
    copyfile([input_path,inputFiles(i).name],[output_path,outputFileNames{i}])
    waitbar(i/length(inputFiles),h)
end
close (h)

%% Task 1 - Response to stimuli

inputFiles = dir([input_path,'*Response*.txt']);
headers = {'subjectID','order','run','before_or_after','session','itemName','bidInd','isMale','onsettime','fixationTime'};
h=waitbar(0,'Copying ResponseToStim files (task 1 out of 3)');
for file = 1:numel(inputFiles)
    data = readtable([input_path,inputFiles(file).name]);
    % delete last column full of NaN
    if all(isnan(data{:,end}))
        data(:,end)=[];
    end
    data.Properties.VariableNames = headers;
    
    % add onset and duration
    data.onset = data.onsettime;
    data.duration = 2*ones(size( data.onset));
    
    % save results with new name
    new_name = name_changer(inputFiles(file).name);
    writetable(data,[output_path,new_name],'Delimiter','\t','WriteRowNames',true)
    waitbar(file/numel(inputFiles),h)
end
close(h)

%% Task 2 - Training

% merging every two training files to one (to match ASC files)

h=waitbar(0,'Copying Training files (task 2 out of 3)');
for subject = 1:numel(subject_numbers)
%     % skip this for loop if already run
%     if length(dir([input_path,'*training_run*.txt'])) == length(dir([output_path,'*training*.txt']))*2
%         break
%     end
    
    subject_training_files = dir([input_path,'*',num2str(subject_numbers(subject)),'*training_run*.txt']);
    for file=1:numel(subject_training_files)
        if mod(file,2) == 0
            continue
        end
        odd_training = readtable([input_path,subject_training_files(file).name]);
        even_training = readtable([input_path,subject_training_files(file+1).name]);
        if (even_training.runNum(2) - odd_training.runNum(1)) ~=1
            error('Training files:\n%s \n%s \ndont match!',...
                subject_training_files(file).name,subject_training_files(file+1).name)
        end
        
        data = vertcat(odd_training,even_training);
        % delete last column full of NaN
        if all(isnan(data{:,end}))
            data(:,end)=[];
        end
        
        % add onset and duration
        data.onset = data.onsetTime;
        data.duration = ones(size( data.onset));
        
        % save results with new name
        new_name = name_changer(subject_training_files(file).name);
        writetable(data,[output_path,new_name],'Delimiter','\t','WriteRowNames',true)
    end
    waitbar(subject/numel(subject_numbers),h)
end
close(h)

%% Task 3 - Probe

inputFiles = dir([input_path,'*Probe_block*.txt']);
h=waitbar(0,'Copying Probe files (task 3 out of 3)');
for file = 1:numel(inputFiles)
    data = readtable([input_path,inputFiles(file).name]);
    % delete last column full of NaN
    if all(isnan(data{:,end}))
        data(:,end)=[];
    end
    
    % add onset and duration
    data.onset = data.onsettime;
    data.duration = data.RT/1000;
    
    % save results with new name
    new_name = name_changer(inputFiles(file).name);
    writetable(data,[output_path,new_name],'Delimiter','\t','WriteRowNames',true)
    waitbar(file/numel(inputFiles),h)
end
close(h)

%% Display summary
[summary] =validate_match(output_path);
