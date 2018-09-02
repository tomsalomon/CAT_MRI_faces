function [personalDetailsAllSubjects] = joinPersonalDetails(experimentName,mainPath,Subjects)
% function [personalDetailsAllSubjects] = joinPersonalDetails(experimentName,mainPath,Subjects)
% This function joins the personal details of the subjects to one matrix
% experimentName: the prefix of subjectID of this experiment (e.g.
% BMI_bs_40)
% mainPath: the path of the main folder of this experiment, in which there
% is the output folder
% Subjects: the number of subjects to be analyzed (e.g. 101:110)

if nargin < 3
    Subjects = [101:120,122:126]; % Define here your subjects' codes.
%exclude:
% 121 - did not look at the images during training
end

if nargin < 2
    experimentName = 'BMI_bf';
end

if nargin < 1
    mainPath = './../';
end

outputPath = [mainPath '/Output'];

personalDetailsAllSubjects = cell(length(Subjects)+1,9);
titles = {'subjectID','order','date','gender(1=female)','age','dominantHand(1=right)','height','weight','occupation'};
personalDetailsAllSubjects(1,:) = titles;

for subjectInd = 1:length(Subjects)
    subjectNum = Subjects(subjectInd);
    filename = strcat(outputPath,sprintf('/%s_%d',experimentName,subjectNum));
    logs = dir(strcat(filename, '_personalDetails','*.txt')) ;
    fid = fopen(strcat(outputPath,'/',logs(end).name));
    Data = textscan(fid, '%s %d %s %d %d %d %d %d %s' , 'HeaderLines', 1); % read in personal details output file into Data ;
    for ind = 1:9 % put the details inside the matrix for all subjects
        personalDetailsAllSubjects{subjectInd+1,ind} = Data{ind};
    end
end

[personalDetailsAllSubjects] = fixPersonalDetailsMatrix(personalDetailsAllSubjects);

end % end main function

function [personalDetailsAllSubjects] = fixPersonalDetailsMatrix(personalDetailsAllSubjects)
for row = 2:size(personalDetailsAllSubjects,1)
    for column = 1:size(personalDetailsAllSubjects,2)
        if length(personalDetailsAllSubjects{row,column})>1
            personalDetailsAllSubjects{row,column} = personalDetailsAllSubjects{row,column}(1);
        end
    end
end % end function fixPersonalDetailsMatrix(personalDetailsAllSubjects)
end