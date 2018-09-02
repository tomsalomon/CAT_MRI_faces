function recognition_confidence(subjectID,test_comp,mainPath,order, sessionNum)

% function recognition_confidence(subjectID,test_comp,mainPath,order, sessionNum)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Rotem Botvinik November 2015 ====================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs the recognition session of the cue-approach task.
% Subjects are presented with the stimuli from the previous sessions (but
% only those that were part of the probe comparisons- as defined hard-coded in this function)
% as well as some items that were not included in the training session, in a random order, and
% should answer whether they recognize each stimuli from the previous
% sessions or not.
% In this version, subjects also indicate their level of confidence
% (high/low/uncertain).
% Then, for every item, they are immediately asked whether this item was paired with a beep during training, while
% again indicating their level of confidence.


% Old stimuli should be located in the folder [mainPath'/stim/']
% New stimuli should be located in the folder [mainPath'/stim/recognitionNew/']

% This version of the function fits the boost version with training only 40
% items!


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'stopGoList_allstim_order%d.txt', order --> Created by the 'sortBdm_Israel' function


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'recognition_confidence_results' num2str(sessionNum) '_' timestamp '.txt''
%   --> Which includes the variables: trialNum (in the newOld recognition task), index
%   of the item (ABC order, old and than new), name of item, whether the item
%   is old (1) or not (0), the subject's answer (1- high confidence old; 2-
%   low confidence old; 3- uncertain; 4- low confidence new; 5- high
%   confidence new), onset time, response key, RT, whether the item was paired with a beep (0- no ; 1-
%   yes) and the subject answer on the beep/nobeep question (0-wasn't
%   asked; 1- high confidence yes; 2- low confidence yes; 3- uncertain; 4-
%   low confidence no; 5- high confidence no), onset time, response key,
%   RT.


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% subjectID = 'test999';
% order = 1;
% test_comp = 4;
% sessionNum = 1;
% mainPath = '/Users/schonberglabimac1/Documents/BMI_BS_40';


tic

rng shuffle
% Screen('Preference', 'SkipSyncTests', 1);

%==========================================================
%% 'INITIALIZE Screen variables to be used in each task'
%==========================================================

Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = max(Screen('Screens'));

pixelSize = 32;
% [w] = Screen('OpenWindow',screennum,[],[0 0 640 480],pixelSize);% %debugging screensize
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

%{
[wWidth, wHeight] = Screen('WindowSize', w);
xcenter = wWidth/2;
ycenter = wHeight/2;


sizeFactor = 0.8;
stimW = 576*sizeFactor;
stimH = 432*sizeFactor;
rect = [xcenter-stimW/2 ycenter-stimH/2 xcenter+stimW/2 ycenter+stimH/2];
%}

% Colors settings
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
% green = [0 255 0];

Screen('FillRect', w, black);
Screen('Flip', w);

% set up screen positions for stimuli
[wWidth, wHeight] = Screen('WindowSize', w);
xcenter = wWidth/2;
ycenter = wHeight/2;


% text settings
theFont = 'Arial';
Screen('TextFont',w,theFont);
Screen('TextSize',w, 40);

HideCursor;

% -----------------------------------------------
%% Load Instructions
% -----------------------------------------------

% Load Hebrew instructions image files
Instructions = dir([mainPath '/Instructions/recognition_confidence.JPG' ]);
Instructions_fmri = dir([mainPath '/Instructions/recognition_confidence.JPG' ]);
Instructions_image = imread([mainPath '/Instructions/' Instructions(1).name]);
Instructions_image_fmri = imread([mainPath '/Instructions/' Instructions_fmri(1).name]);

% -----------------------------------------------
%% Load Questions Images
% -----------------------------------------------

% Load Hebrew questions image files
goNoGoQuestion = dir([mainPath '/Instructions/recognition_goNoGo_question.JPG' ]);
newOldQuestion = dir([mainPath '/Instructions/recognition_oldNew_question.JPG' ]);
goNoGoQuestion_image = imread([mainPath '/Instructions/' goNoGoQuestion(1).name]);
newOldQuestion_image = imread([mainPath '/Instructions/' newOldQuestion(1).name]);
% size_goNoGoQuestion_image = size(goNoGoQuestion_image);
% size_goNoGoQuestion_image = size_goNoGoQuestion_image(1:2);
question1_height = size(newOldQuestion_image,1);
question1_width = size(newOldQuestion_image,2);
question2_height = size(goNoGoQuestion_image,1);
question2_width = size(goNoGoQuestion_image,2);

question1_location = [xcenter-question1_width/2 0.3*ycenter-question1_height/2 xcenter+question1_width/2 0.3*ycenter+question1_height/2];
question2_location = [xcenter-question2_width/2 0.3*ycenter-question2_height/2 xcenter+question2_width/2 0.3*ycenter+question2_height/2];

% -----------------------------------------------
%% Load Answers Images
% -----------------------------------------------

% Load Hebrew answers image files
recognition_answers = dir([mainPath '/Instructions/recognition_answers.jpg' ]);
recognition_answers_image = imread([mainPath '/Instructions/' recognition_answers(1).name]);
answer_images = cell(1,5);
for answerInd = 1:5
    answers = dir([mainPath '/Instructions/recognition_' num2str(answerInd) '.jpg' ]);
    answer_images{answerInd} = imread([mainPath '/Instructions/' answers(1).name]);
end

% the dimensions of the answers' images are 1288 X 142
answers_width = 1342;
answers_height = 154;
answers_location = [xcenter-answers_width/2 1.75*ycenter-answers_height/2 xcenter+answers_width/2 1.75*ycenter+answers_height/2];

%---------------------------------------------------------------
%% 'GLOBAL VARIABLES'
%---------------------------------------------------------------
timeNow = clock;
hours = sprintf('%02d', timeNow(4));
minutes = sprintf('%02d', timeNow(5));
timestamp = [date,'_',hours,'h',minutes,'m'];

outputPath = [mainPath '/Output'];

%---------------------------------------------------------------
%% 'Assign response keys'
%---------------------------------------------------------------
KbName('UnifyKeyNames');

if test_comp == 1
%     leftresp = 'b';
%     rightresp = 'y';
    %     badresp = 'x';
else
%     leftresp = 'u';
%     rightresp = 'i';
    %     badresp = 'x';
    key1 = '1'; % high confidence yes / beep
    key2 = '2'; % low confidence yes / beep
    key3 = '3'; % uncertain
    key4 = '4'; % low confidence no / no beep
    key5 = '5'; % high confidence no / no beep
end


%---------------------------------------------------------------
%% 'DEFINE stimuli of interest'
%---------------------------------------------------------------

switch order
    case 1
        %   comparisons of interest
        % - - - - - - - - - - - - - - -
        HV_beep =   [7 10 12 13 15 18]; % HV_beep
        HV_nobeep = [8 9 11 14 16 17]; % HV_nobeep
        
        LV_beep =   [44 45 47 50 52 53]; % LV_beep
        LV_nobeep = [43 46 48 49 51 54]; % LV_nobeep
        
        
        %   sanity check comparisons - just NOGO
        % - - - - - - - - - - - - - - 
        sanityHV_nobeep = [5 6]; % HV_nobeep
        sanityLV_nobeep = [55 56]; % LV_nobeep
        
    case 2
        
        %   comparisons of interest
        % - - - - - - - - - - - - - - -
        HV_beep =   [8 9 11 14 16 17]; % HV_beep
        HV_nobeep = [7 10 12 13 15 18]; % HV_nobeep
        
        
        LV_beep =   [43 46 48 49 51 54]; % LV_beep
        LV_nobeep = [44 45 47 50 52 53]; % LV_nobeep
        
                
        %   sanity check comparisons - just NOGO
        % - - - - - - - - - - - - - - -
        sanityHV_nobeep = [5 6]; % HV_nobeep
        sanityLV_nobeep = [55 56]; % LV_nobeep
        
end % end switch order


%---------------------------------------------------------------
%% 'READ data about the stimuli - Go \ NoGo
%---------------------------------------------------------------

%   'Reading in the sorted BDM list - defines which items will be GO\NOGO'
% - - - - - - - - - - - - - - -
file = dir([outputPath '/' subjectID sprintf('_stopGoList_allstim_order%d.txt', order)]);
fid = fopen([outputPath '/' sprintf(file(length(file)).name)]);
vars = textscan(fid, '%s %d %d %f %d') ;% these contain everything from the sortbdm
fclose(fid);

allOldStimName = vars{1};
allGoNoGo = vars{2};
allIsGo = zeros(length(allGoNoGo),1);
allIsGo(allGoNoGo == 11 | allGoNoGo == 22) = 1;
allBidInd = vars{3};
% bidValue = vars{4};
oldStimName = allOldStimName([HV_beep HV_nobeep LV_beep LV_nobeep sanityHV_nobeep sanityLV_nobeep]);
% goNoGo = allGoNoGo([HV_beep HV_nobeep LV_beep LV_nobeep]);
isGo = allIsGo([HV_beep HV_nobeep LV_beep LV_nobeep   sanityHV_nobeep sanityLV_nobeep]);
bidInd = allBidInd([HV_beep HV_nobeep LV_beep LV_nobeep   sanityHV_nobeep sanityLV_nobeep]);

[oldStimName, indSortedOldStimName] = sort(oldStimName); % sort old stimuli ABC

%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------

newStimName = dir([mainPath '/stim/recognitionNew/*.jpg']); % Read new stimuli

% Read old images to a cell array
imgArraysOld = cell(1,length(oldStimName));
for i = 1:length(oldStimName)
    imgArraysOld{i} = imread([mainPath '/stim/' oldStimName{i}]);
end
Old = ones(length(oldStimName),1);

% Read new images to a cell array
imgArraysNew = cell(1,length(newStimName));
for i = 1:length(newStimName)
    imgArraysNew{i} = imread([mainPath '/stim/recognitionNew/' newStimName(i).name]);
end
New = zeros(length(newStimName),1);

isOld = [Old; New]; % Create an array indicating whether an item is old (1) or not (0)

%---------------------------------------------------------------
%% 'ORGANIZE data about the stimuli - Go \ NoGo
%---------------------------------------------------------------

% Add zeros for the goNoGo, isGo, bidInd and bidValue of the new items
% - - - - - - - - - - - - - - -

sortedIsGo = isGo(indSortedOldStimName);
sortedIsGo(length(oldStimName)+1:length(oldStimName)+length(newStimName)) = 0;


sortedBidInd = bidInd(indSortedOldStimName);
sortedBidInd(length(oldStimName)+1:length(oldStimName)+length(newStimName)) = 0;

%---------------------------------------------------------------
%% 'SHUFFLE data about the stimuli - Go \ NoGo
%---------------------------------------------------------------

% Merge the old and new lists, and shuffle them

% Add the names of the new stimuli to stimName
stimName = cell(1, length(oldStimName) + length(newStimName));
stimName(1:length(oldStimName)) = oldStimName;

for newStimInd = 1:length(newStimName)
    stimName{length(oldStimName)+newStimInd} = newStimName(newStimInd).name;
end

[shuffledlist, shuffledlistInd] = Shuffle(stimName);
imgArrays = [imgArraysOld imgArraysNew];
imgArrays = imgArrays(shuffledlistInd);
shuffledIsOld = isOld(shuffledlistInd);
shuffledSortedIsGo = sortedIsGo(shuffledlistInd);
shuffledSortedBidInd = sortedBidInd(shuffledlistInd);


% r = Shuffle(1:4);
% onsetlist = load(['Onset_files/sweet_salty_onset_' num2str(r(1)) '.mat']);
% onsetlist = onsetlist.onsetlist;

% ListenChar(2); % suppresses terminal ouput

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1 = fopen([outputPath '/' subjectID '_recognition_confidence_results' num2str(sessionNum) '_' timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\torder\titemIndABC\tstimName\tbidInd\truntrial\tisOld?\tsubjectAnswerIsOld\tonsettime_isOld\tresp_isOld\tRT_isOld\tisGo?\tsubjectAnswerIsGo\tonsettime_isGo\tresp_isGo\tRT_isGo\n'); %write the header line

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, 40);

if test_comp == 1
   Screen('PutImage',w,Instructions_image_fmri);    
    
else
   Screen('PutImage',w,Instructions_image);    
end
Screen(w,'Flip');


noresp = 1;
while noresp,
    [keyIsDown] = KbCheck(-1); % deviceNumber=keyboard
    if keyIsDown && noresp,
        noresp = 0;
    end;
end

if test_comp == 1
    CenterText(w,'GET READY! Waiting for trigger', white, 0, 0);
    Screen('Flip',w);
    % escapeKey = KbName('space');
    escapeKey = KbName('t');
    while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown && keyCode(escapeKey)
            break;
        end
    end    
    DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected  
end; % end if test_comp == 1

WaitSecs(0.001);
% anchor = GetSecs;

Screen('TextSize',w, 60);
Screen('DrawText', w, '+', xcenter, ycenter, white);
Screen(w,'Flip');
WaitSecs(1);

KbQueueCreate;

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------
% pre-allocate vectors
isOldAnswers = zeros(1, length(stimName)); % An array for the results
isGoAnswers = zeros(1, length(stimName)); % An array for the results

runStart = GetSecs;

% for trial = 1:6 % for debugging
for trial = 1:length(stimName)
    
    % isOld part
    
    %-----------------------------------------------------------------
    % display image
    % self-paced; next image will only show after response
    
    Screen('PutImage',w, imgArrays{trial}); % display item
    Screen('TextSize',w, 40);
    Screen('PutImage',w, newOldQuestion_image,question1_location); % display question
    Screen('PutImage',w, recognition_answers_image,answers_location); % display answers
    Screen(w,'Flip');
    StimOnset_isOld = GetSecs;
    
    KbQueueStart;
    %-----------------------------------------------------------------
    % get response
    
    
    noresp = 1;
    while noresp
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(-1);
        
        if keyIsDown && noresp
            findfirstPress = find(firstPress);
            respTime_isOld = firstPress(findfirstPress(1))-StimOnset_isOld;
            tmp = KbName(findfirstPress);
            if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                tmp = char(tmp);
            end
            response_isOld = tmp(1);
            if response_isOld==key1||response_isOld==key2||response_isOld==key3||response_isOld==key4||response_isOld==key5 % A valid response is only 1,2,3,4 or 5
            noresp = 0;
            end
            
        end % end if keyIsDown && noresp
        
    end % end while noresp
    
    
    
    %-----------------------------------------------------------------   
    % save the subject's response
    isOldAnswers(trial) = str2double(response_isOld);
    
    
    %-----------------------------------------------------------------
    % redraw text output with the appropriate colorchanges to highlight
    % response
    Screen('PutImage',w,imgArrays{trial}); % display item
    Screen('TextSize',w, 40);
    Screen('PutImage',w, newOldQuestion_image,question1_location); % display question
    Screen('PutImage',w, answer_images{str2double(response_isOld)},answers_location); % display answers
    Screen(w,'Flip');
    WaitSecs(0.5);
    
    %-----------------------------------------------------------------
%     % show fixation ITI
%     Screen('TextSize',w, 60);
%     Screen('DrawText', w, '+', xcenter, ycenter, white);
%     Screen(w,'Flip');
%     WaitSecs(1);

    KbQueueFlush;    
    
    
    % Go\NoGo question
    Screen('PutImage',w, imgArrays{trial}); % display item
    Screen('TextSize',w, 40);
    Screen('PutImage',w, goNoGoQuestion_image,question2_location); % display question2
    Screen('PutImage',w, recognition_answers_image,answers_location); % display answers
    Screen(w,'Flip');
    StimOnset_isGo = GetSecs;
    
    KbQueueStart;
    %-----------------------------------------------------------------
    % get response
    
    
    noresp = 1;
    while noresp
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(-1);
        
        if keyIsDown && noresp
            findfirstPress = find(firstPress);
            respTime_isGo = firstPress(findfirstPress(1))-StimOnset_isGo;
            tmp = KbName(findfirstPress);
            if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                tmp = char(tmp);
            end
            response_isGo = tmp(1);
            if response_isGo==key1||response_isGo==key2||response_isGo==key3||response_isGo==key4||response_isGo==key5 % A valid response is only 1,2,3,4 or 5
            noresp = 0;
            end
            
        end % end if keyIsDown && noresp
        
    end % end while noresp
    
    
    
    %-----------------------------------------------------------------   
    % save the subject's response
    isGoAnswers(trial) = str2double(response_isGo);
    
    
    %-----------------------------------------------------------------
    % redraw text output with the appropriate colorchanges to highlight
    % response
    Screen('PutImage',w,imgArrays{trial}); % display item
    Screen('TextSize',w, 40);
    Screen('PutImage',w, goNoGoQuestion_image,question2_location); % display question
    Screen('PutImage',w, answer_images{str2double(response_isGo)},answers_location); % display answers
    Screen(w,'Flip');
    WaitSecs(0.5);
    
    %-----------------------------------------------------------------
    % show fixation ITI
    Screen('TextSize',w, 60);
    Screen('DrawText', w, '+', xcenter, ycenter, white);
    Screen(w,'Flip');
    WaitSecs(1);
    
    %-----------------------------------------------------------------
    % Write to output files
    
    fprintf(fid1,'%s\t%d\t%d\t%s\t%d\t%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\t%d\t%s\t%d\t\n', subjectID, order, shuffledlistInd(trial), shuffledlist{trial}, shuffledSortedBidInd(trial), trial, shuffledIsOld(trial), isOldAnswers(trial), StimOnset_isOld-runStart, response_isOld, respTime_isOld, shuffledSortedIsGo(trial), isGoAnswers(trial), StimOnset_isGo-runStart, response_isGo, respTime_isGo);
    % fprintf(fid1,'subjectID\torder\titemIndABC\tstimName\tbidInd\truntrial\tisOld?\tsubjectAnswerIsOld\tonsettime_isOld\tresp_isOld\tRT_isOld\tisGo?\tsubjectAnswerIsGo\tonsettime_isGo\tresp_isGo\tRT_isGo\n'); %write the header line

    KbQueueFlush;
    
end % end loop for trial = 1:length(food_images);

% Close open files
fclose(fid1);


% Save variables to mat file
outfile = strcat(outputPath,'/', sprintf('%s_recognition_confidence_%s.mat',subjectID, timestamp));

% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;

run_info.script_name = mfilename;
clear Instructions_image Instructions_image_fmri goNoGoQuestion_image newOldQuestion_image imgArrays imgArraysNew imgArraysOld answer_images recognition_answers_image newOldQuestion_Image goNoGoQuestion_Image;
save(outfile);


% End of session screen       
        Screen('TextSize',w, 40);
        CenterText(w,'Thank you!', white,0,-50);
        CenterText(w,'The experiment is over. Please call the experimenter', white,0,50);
        Screen(w,'Flip');

% Closing
WaitSecs(4);
toc
ShowCursor;
Screen('CloseAll');

end % end function