
function Recognition_results=recognition_analysis(subjects,outpath)
% ********************* Recognition Analysis Function *********************
% ********************* By Tom Salomon, February 2016 *********************
% *************************************************************************
%
% This function is used to analyse recognition with confidence task's results. 
% It requires as input a vector with subject numbers, and outputs a matrix
% with recognition results for all subjects. these can later be correlated
% with probe results. 

if nargin<1
    subjects=[101:102,104:117,119:120]; % Define here your subjects' codes.
    %exclude: none
end

if nargin<=1
    outpath='./../Output/';
end
Recognition_results=zeros(length(subjects),11);

for subjInd=1:length(subjects)
    
    % find recognition output file
    recognitionLogs=dir([outpath,'*',num2str(subjects(subjInd)),'_recognition_confidence*.txt']) ;
    fid=fopen(strcat(outpath,recognitionLogs(1).name));

    RecognitionData=textscan(fid, '%s %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f' , 'HeaderLines', 1); %read output file
    %   1 - subjectID           2 - order           3 - itemIndABC      4 - stimName	
    %   5 - bidInd              6 - runtrial        7 - isOld?          8 - subjectAnswerIsOld	
    %   9 - onsettime_isOld     10 - resp_isOld     11 - RT_isOld       12 - isGo?	
    %   13 - subjectAnswerIsGo	14 - onsettime_isGo 15 - resp_isGo      16 - RT_isGo
    
    fclose(fid);
    
    RT_isOld=RecognitionData{11};
    IsOld=RecognitionData{7};
    subjectAnswerOldConfidence=RecognitionData{8};
 
    IsGo=RecognitionData{12};
    subjectAnswerGoConfidence=RecognitionData{13};
    
    % create binary response variable where: 0 - stimuli is new/NoGo, 
    %1 - Stimulus is old/Go, 999 - not sure.
    subjectAnswerOld=zeros(length(subjectAnswerOldConfidence),1); 
    subjectAnswerOld(subjectAnswerOldConfidence==3)=999;
    subjectAnswerOld(subjectAnswerOldConfidence<=2)=1;
    
    subjectAnswerGo=zeros(length(subjectAnswerGoConfidence),1);
    subjectAnswerGo(subjectAnswerGoConfidence==3)=999;
    subjectAnswerGo(subjectAnswerGoConfidence<=2)=1;
    
    % Determine if response is correct
    IsOldCorrectResponse=IsOld==subjectAnswerOld;
    IsGoCorrectResponse=IsGo==subjectAnswerGo;
    
    % Signal detection results
    IsOldTruePositive=IsOld==1&subjectAnswerOld==1;
    IsOldTrueNegative=IsOld==0&subjectAnswerOld==0;
    IsOldMiss=IsOld==1&subjectAnswerOld==0;
    IsOldFalseAlarm=IsOld==0&subjectAnswerOld==1;
    
    IsGoTruePositive=IsGo==1&subjectAnswerGo==1;
    IsGoTrueNegative=IsGo==0&subjectAnswerGo==0;
    IsGoMiss=IsGo==1&subjectAnswerGo==0;
    IsGoFalseAlarm=IsGo==0&subjectAnswerGo==1;
    
    % summarize results in one matrix
    Recognition_results(subjInd,1)=subjects(subjInd); % Subject ID
    Recognition_results(subjInd,2)=sum(IsOldCorrectResponse)/length(IsOld); % Is old correct
    Recognition_results(subjInd,3)=sum(IsGoCorrectResponse&IsOld==1)/sum(IsOld==1); % Is Go correct
    
    Recognition_results(subjInd,4)=sum(IsOldTruePositive)/sum(IsOld==1); % Is old True-Positive
    Recognition_results(subjInd,5)=sum(IsOldTrueNegative)/sum(IsOld==0); % Is old True-Negative
    Recognition_results(subjInd,6)=sum(IsOldMiss)/sum(IsOld==1); % Is old Miss
    Recognition_results(subjInd,7)=sum(IsOldFalseAlarm)/sum(IsOld==0); % Is old False-Alarm
    
    Recognition_results(subjInd,8)=sum(IsGoTruePositive)/sum(IsGo==1); % Is Go True-Positive
    Recognition_results(subjInd,9)=sum(IsGoTrueNegative)/sum(IsGo==0); % Is Go True-Negative
    Recognition_results(subjInd,10)=sum(IsGoMiss)/sum(IsGo==1); % Is Go Miss
    Recognition_results(subjInd,11)=sum(IsGoFalseAlarm)/sum(IsGo==0); % Is Go False-Alarm
    
    RT(subjInd,:)=RT_isOld;
end
end



