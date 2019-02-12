
function differences = timeBetweenSessions(subjects)
%This script calculates the time elapsed between sessions, on average, the SD, min and max (in number of days) 

if nargin < 1
subjects=[102,104:105,108,110:112,114,117,120:123,127,129:131,133:136,138:140,144]; %25 subjects
end

session1_outputPath = './../Output/'; % write/correct ccording to the path of the first session results
session2_outputPath = './../Output/followup/'; % write/correct ccording to the path of the second session results

%logs2session=dir([session2_outputPath,'*block_04_run2*.txt']);
diff_by_subject= zeros(length(subjects),2);


for subjectInd = 1:length(subjects)
    logs2session = dir([session2_outputPath,'*',num2str(subjects(subjectInd)),'*block_04_run2*.txt']);
    string_name_end=strfind(logs2session.name,'_probe_block')-1;
    sub_name=logs2session.name(1:string_name_end);
    logs1session = dir([session1_outputPath,sub_name,'*_probe_block_01_run1*.txt']) ;
        
    NumDays = round(daysact(logs1session.date,  logs2session.date));
    diff_by_subject(subjectInd,1)=str2double(sub_name(end-2:end));
    diff_by_subject(subjectInd,2)=NumDays;
end
differences=sort(diff_by_subject(:,2));
n=length(differences);
fprintf('%i subjects',n);
fprintf('\nMean Days: %.2f (SD=%.2f; range=%.0f-%.0f, median = %.0f)\n',mean(differences),std(differences),min(differences),max(differences),median(differences));
fprintf('\nQ1 - Q3 range = %.0f - %.0f\n',differences(round(n*0.25)),differences(round(n*0.75)));

