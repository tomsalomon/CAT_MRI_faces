

%This script calculates the time elapsed between sessions, on average, the SD, min and max (in number of days) 
% 
% if nargin < 3
%     %subjects =  [101:103 109:110 112 113 117 119 122 123]; % write here only the subjects that should be analyzed (were not excluded)
% load('subjects')
% end
%     experimentName = '*'; %this should be compatible with the prefix of the subjects serial numbers

session1_outputPath = './../Output/'; % write/correct ccording to the path of the first session results
session2_outputPath = './../Output/followup/'; % write/correct ccording to the path of the second session results

logs2session=dir([session2_outputPath,'*block_04_run2*.txt']);
diff_by_subject= zeros(length(logs2session),2);


for subjectInd = 1:length(logs2session)
    string_name_end=strfind(logs2session(subjectInd).name,'_probe_block')-1;
    sub_name=logs2session(subjectInd).name(1:string_name_end);
    logs1session = dir([session1_outputPath,sub_name,'*_probe_block_01_run1*.txt']) ;
        
    NumDays = round(daysact(logs1session.date,  logs2session(subjectInd).date));
    diff_by_subject(:,1)=str2double(sub_name(end-2:end));
    diff_by_subject(subjectInd,2)=NumDays;
end

Days_data(1)=mean(diff_by_subject(:,2));
Days_data(2)=std(diff_by_subject(:,2));
Days_data(3)=min(diff_by_subject(:,2));
Days_data(4)=max(diff_by_subject(:,2));

fprintf('%.0f subjects',length(diff_by_subject));
fprintf('\nMean Days: %.2f (SD=%.2f; range=%.0f-%.0f)\n',Days_data(1),Days_data(2),Days_data(3),Days_data(4));

