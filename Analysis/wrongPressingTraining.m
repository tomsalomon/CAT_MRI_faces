function [wrongPressingAllSubjects] = wrongPressingTraining(mainPath, experimentName, Subjects)
% function [wrongPressingAllSubjects] = wrongPressingTraining(mainPath, experimentName, Subjects)
% this function calculates how many times each subject pressed when no beep
% was heard (wrong positive)

if nargin < 3
    Subjects = 101:104; % write here only the subjects that should be analyzed (were not excluded)
    % exclude:
    % 
end

if nargin < 2
    experimentName = 'MRI_faces';
end

if nargin < 1
    mainPath = './../';
end

analysisOutputPath = [mainPath '/Output'];
wrongPressingAllSubjects = zeros(length(Subjects),2);
wrongPressingAllSubjects(:,1) = Subjects;

for subjectInd = 1:length(Subjects)
    % join all the training files of the subject to one matrix
%     subjectTrainingData = joinTraining(mainPath, experimentName, Subjects(subjectInd));
    subjectTrainingData=Training_recode(Subjects(subjectInd));
    % search the subject data for trials of type 12 or 24 in which a button
    % was pressed
    countWrongPressing = sum(subjectTrainingData(:,8)==12 | subjectTrainingData(:,8)==24);
    countMissedPressing = sum(subjectTrainingData(:,8)==1 | subjectTrainingData(:,8)==2);
    countLatePressing = sum(subjectTrainingData(:,8)==1100 | subjectTrainingData(:,8)==2200);

    wrongPressingAllSubjects(subjectInd,2) = countWrongPressing;
    fprintf('Subject # %i: pressed when not needed - %i, missed the cue - %i, Pressed late - %i trials of training\n', Subjects(subjectInd),countWrongPressing,countMissedPressing,countLatePressing);
end % end for subjectInd = 1:length(Subjects)



end % end function

