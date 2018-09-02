function recognition_confidence_demo(test_comp,mainPath)

% function recognition_confidence_demo(subjectID,test_comp,mainPath,order, sessionNum)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Rotem Botvinik November 2015 ====================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs a demo for the recognition session of the cue-approach task.
% Subjects are presented with demo stimuli, and should answer whether they
% recognize each stimuli from the previous sessions or not.
% In this version, subjects also indicate their level of confidence
% (high/low/uncertain).
% Then, for every item, they are immediately asked whether this item was
% paired with a beep during training, while again indicating their level of confidence.


% Demo stimuli should be located in the folder [mainPath'/Stim/demo']

% This version of the function fits the boost version with training only 40
% items!


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   none...


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   none...


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% subjectID = 'test1';
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

[wWidth, wHeight] = Screen('WindowSize', w);
xcenter = wWidth/2;
ycenter = wHeight/2;

sizeFactor = 0.8;
stimW = 576*sizeFactor;
stimH = 432*sizeFactor;
rect = [xcenter-stimW/2 ycenter-stimH/2 xcenter+stimW/2 ycenter+stimH/2];


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
Instructions = dir([mainPath '/Instructions/recognition_confidence_demo.JPG' ]);
Instructions_image = imread([mainPath '/Instructions/' Instructions(1).name]);

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
% timeNow = clock;
% hours = sprintf('%02d', timeNow(4));
% minutes = sprintf('%02d', timeNow(5));
% timestamp = [date,'_',hours,'h',minutes,'m'];
% 
% outputPath = [mainPath '/Output'];

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
%% 'LOAD image arrays'
%---------------------------------------------------------------

demoStimName = dir([mainPath '/Stim/demo/*.jpg']); % Read demo stimuli

% Read old images to a cell array
imgArraysDemo = cell(1,length(demoStimName));
for i = 1:length(demoStimName)
    imgArraysDemo{i} = imread([mainPath '/Stim/demo/' demoStimName(i).name]);
end

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, 40);
Screen('PutImage',w,Instructions_image);
Screen(w,'Flip');


noresp = 1;
while noresp,
    [keyIsDown] = KbCheck(-1); % deviceNumber=keyboard
    if keyIsDown && noresp,
        noresp = 0;
    end;
end

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

% runStart = GetSecs;

shuffleNames = randperm(length(demoStimName));

for trial = shuffleNames(1:3)  
    % isOld part
    
    %-----------------------------------------------------------------
    % display image
    % self-paced; next image will only show after response
    
    Screen('PutImage',w, imgArraysDemo{trial}); % display item
    Screen('TextSize',w, 40);
    Screen('PutImage',w, newOldQuestion_image,question1_location); % display question
    Screen('PutImage',w, recognition_answers_image,answers_location); % display answers
    Screen(w,'Flip');
    % StimOnset_isOld = GetSecs;
    
    KbQueueStart;
    %-----------------------------------------------------------------
    % get response
    
    
    noresp = 1;
    while noresp
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(-1);
        
        if keyIsDown && noresp
            findfirstPress = find(firstPress);
            % respTime_isOld = firstPress(findfirstPress(1))-StimOnset_isOld;
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
    % redraw text output with the appropriate colorchanges to highlight
    % response
    Screen('PutImage',w,imgArraysDemo{trial}); % display item
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
    Screen('PutImage',w, imgArraysDemo{trial}); % display item
    Screen('TextSize',w, 40);
    Screen('PutImage',w, goNoGoQuestion_image,question2_location); % display question2
    Screen('PutImage',w, recognition_answers_image,answers_location); % display answers
    Screen(w,'Flip');
    % StimOnset_isGo = GetSecs;
    
    KbQueueStart;
    %-----------------------------------------------------------------
    % get response
    
    
    noresp = 1;
    while noresp
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(-1);
        
        if keyIsDown && noresp
            findfirstPress = find(firstPress);
            % respTime_isGo = firstPress(findfirstPress(1))-StimOnset_isGo;
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
    % redraw text output with the appropriate colorchanges to highlight
    % response
    Screen('PutImage',w,imgArraysDemo{trial}); % display item
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
    
    
    KbQueueFlush;
    
end % end loop for trial = 1:length(food_images);


% End of session screen

Screen('TextSize',w, 40);
CenterText(w,'Thank you!', white,0,-50);
CenterText(w,'The demo is done', white,0,50);
Screen(w,'Flip');

% Closing

WaitSecs(3);
toc
ShowCursor;
Screen('CloseAll');


end % end function