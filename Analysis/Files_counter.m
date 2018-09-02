%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~ Files Counter ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% ~~~~~~~~~~~~~ Written by: Tom Salomon, February 2nd, 2017 ~~~~~~~~~~~~~
% =======================================================================
%
% Info:
% This code will map your experiment output directory. It can be used to
% make sure you have no subjects with missing or duplicated data files.
% Change the variables in the PARAMETERS section in order to fit for your
% experiment. The data will be organized into a table which will make it
% easy to spot subjects with irregular number of output files.
% 
% Also, here is some themed ASCII art for Nadav :-) 
%                                                                     .-') _  
%                                                                    ( OO ) ) 
%  .---.          .-----.           .-----.                      ,--./ ,--,'  
% /_   |         / ,-.   \         /  -.   \                     |   \ |  |\  
%  |   |         '-'  |  |         '-' _'  |                     |    \|  | ) 
%  |   |            .'  /             |_  <                      |  .     |/  
%  |   |          .'  /__          .-.  |  |                     |  |\    |   
%  |   |.-.      |       |.-.      \ `-'   /      .-..-..-.      |  | \   |   
%  `---'',/      `-------'',/       `----''       `-'`-'`-'      `--'  `--'   
%  
% ENJOY!

clear;

%% PARAMETERS - Define according to your experiment:
outpath = './../Output/';
% outpath= './../Output/followup/'; %for followup
exp_name='MRI_faces_';
subjects=101:143;
ending='txt'; % leave empty string for all file types
% use a unique string to identify files from each task
output_files_titles={'binary_ranking','ItemRankingResults','personalDetails','ResponseToStimuli','stimuliforprobe','stopgolist','training_run','probe_block','faceLocalizer','recognition'};

%% preallocation
num_of_files=nan(length(subjects),2+length(output_files_titles));
num_of_files(:,1)=subjects';
out_files=cell(1,length(subjects));

%% calculations
for sub=1:length(subjects);
    out_files_all=dir([outpath,exp_name,num2str(subjects(sub)),'*.',ending]);
    if ~isempty(out_files_all) % if subject has no files - leave as NaN
        
        out_files_all_names=struct2cell(rmfield(out_files_all,{'date','bytes','isdir','datenum'}))';
        
        % ignore crashing logs and demo files
        crashing_logs=regexpi(out_files_all_names,'crashing');
        demo=strfind(out_files_all_names,'demo');
        out_files{sub}=out_files_all_names(cellfun(@isempty,crashing_logs)&cellfun(@isempty,demo));
        
        num_of_files(sub,2)=length(out_files{sub}); % total number of files
        for part=1:length(output_files_titles) % number of files for each experimental part
            num_of_files(sub,part+2)=length(cell2mat(regexpi(out_files{sub},output_files_titles{part})));
        end
        
    end
end


%% Finalize into a nice Table format
table_titles=[{'SubID','TotalFiles'},output_files_titles];
FilesTable=array2table(num_of_files,'VariableNames',table_titles);
disp(FilesTable)


%% Test if all files are mapped
maping_test=[num_of_files(:,2),sum(num_of_files(:,3:end),2)];
% if you get this warning, your output_files_titles may be either non
% exhaustive or overlapping
if nanmean(maping_test(:,1)-maping_test(:,2))~=0
    disp('WARNING:')
    disp('Total number of files did not match number of files in the categories you defined')
    disp('You may need to redefine your output files categories to be exhaustive')
end