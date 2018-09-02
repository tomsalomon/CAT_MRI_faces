% function recognitionGoNoGo_Israel(subjectID, test_comp, order, mainPath, sessionNum)

% function recognitionGoNoGo_Israel(subjectID, test_comp, order, mainPath, sessionNum);

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Rotem Botvinik May 2015 ====================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs the second part of the memory (recognition) session of the
% boost (cue-approach) task.
% Subjects are presented with the stimuli they claimed to be old (included
% in the previous sessions of the cue-approach task) in the first part of
% the memory (recognition) session in a random order, and should answer whether they
% think this item was a GO (beep) or NOGO (no beep) item in the training
% session.

% This version of the function fits the boost version with training only 40
% items!

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   ''recognitionNewOld_results' num2str(sessionNum) '_' timestamp
%   '.txt'' --> Created by the recognitionNewOld function



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   ''recognitionGoNoGo_results' num2str(sessionNum) '_' date '.txt''
%   Which includes the variables: trialNum (in the GoNoGo recognition task), index
%   of the item (ABC order, old and than new), name of item, whether the item
%   is old (1) or not (0), the subject's answer (0- not included; 1-
%   included), whether the item is go (1) or nogo (0) item, the subject's
%   answer (o- noBeep, 1- Beep), the index of the bid (high to low)

%   ''recognitionoGoNoGo' num2str(sessionNum) '_' timestamp '.txt''


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% subjectID = 'test999';
% order = 1;
% test_comp = 4;
% sessionNum = 1;
% mainPath = '/Users/schonberglabimac1/Documents/Boost_Israel_New_Rotem_mac';

clear all

tic

rng shuffle

% =========================================================================
% Get input args and check if input is ok
% =========================================================================

oksessionNum = [1 2 3];
okComputer = [0 1 2 3 4 5];
okOrder = [1 2];

% input checkers
subjectID = input('Subject code: ','s');
[subjectID_num,okID]=str2num(subjectID(end-2:end));
while okID==0
    disp('ERROR: Subject code must contain 3 characters numeric ending, e.g "BMI_bf_101". Please try again.');
    subjectID = input('Subject code:','s');
    [subjectID_num,okID]=str2num(subjectID(end-2:end));
end

% Assign order
% --------------------------
% give order value of '1' or '2' for subjects with odd or even ID, respectively
if mod(subjectID_num,2) == 1 % subject code is odd
    order = 1;
else % subject code is even
    order = 2;
end

sessionNum = input('Enter session number (1 if first for this subject): ');
while isempty(sessionNum) || sum(oksessionNum==sessionNum)~=1
    disp('ERROR: input must be 1 or 2 or 3 . Please try again.');
    sessionNum = input('Enter session number (1 if first for this subject): ');
end

% =========================================================================
% set the computer and path
% =========================================================================

test_comp = input('Which computer are you using? 5 MacBookPro1, 4 new mac, 3 Rotem_PC, 2 Toms_iMac, 1 MRI, 0 if testooom: ');
while isempty(test_comp) || sum(okComputer==test_comp)~=1
    disp('ERROR: input must be 0,1,2,3,4 or 5. Please try again.');
    test_comp = input('Which computer are you using? 5 MacBookPro1, 4 new mac, 3 Rotem_PC, 2 Toms_iMac, 1 MRI, 0 if testooom: ');
end

% Set main path
mainPath=pwd;
% switch test_comp
%     case 0
%         mainPath = '~\Documents\Boost_Short\Output';
%     case 1
%         mainPath = '/Users/schonberglab_laptop1/Documents/Rotem/BMI_MRI_snacks_40';
%     case 2
%         mainPath = 'dropbox\trainedInhibition\Boost_Israel';
%     case 3
%         mainPath = 'D:\Rotem\Dropbox\Rotem\experiments\BMI_MRI_snacks_40\BMI_MRI_snacks_40';
%     case 4
%         mainPath = '/Users/schonberglabimac1/Documents/Boost_Israel_New_Rotem_mac';
%     case 5
%         mainPath = '/Users/schonberglab_laptop1/Documents/Rotem/BMI_MRI_snacks_40';
% end % end switch

outputPath = [mainPath '/Output'];

% % If fMRI experiment - wait for trigger
% if test_comp == 1 % If it's an fMRI experiment, let the experimenter control when to start
%     okStart = 1;
%     should_start = input('Experimenter - enter 1 to start: ');
%     while isempty(should_start) || sum(okStart == should_start) ~=1
%         disp('ERROR: input must be 1. Please try again.');
%         should_start = input('Experimenter - enter 1 to start: ');
%     end
% end % end if test_comp == 1

HideCursor;

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


% % Set the colors
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
green = [0 255 0];

Screen('FillRect', w, black);  % NB: only need to do this once!
Screen('Flip', w);

% Set up screen positions for stimuli
[wWidth, wHeight] = Screen('WindowSize', w);
xcenter = wWidth/2;
ycenter = wHeight/2;


% Text settings
theFont ='Arial';
Screen('TextFont',w,theFont);
Screen('TextSize',w, 40);

% -----------------------------------------------
%% Load Instructions
% -----------------------------------------------

% Load Hebrew instructions image files
Instructions = dir([mainPath '/Instructions/recognitionGoNoGo.JPG' ]);
Instructions_fmri = dir([mainPath '/Instructions/fmri_recognitionGoNoGo.JPG' ]);
Instructions_image = imread([mainPath '/Instructions/' Instructions(1).name]);
Instructions_image_fmri = imread([mainPath '/Instructions/' Instructions_fmri(1).name]);


%---------------------------------------------------------------
%% 'GLOBAL VARIABLES'
%---------------------------------------------------------------
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',min,'m'];

%---------------------------------------------------------------
%% 'ASSIGN response keys'
%---------------------------------------------------------------
KbName('UnifyKeyNames');

if test_comp == 1
    leftresp = 'b';
    rightresp = 'y';
%     badresp = 'x';
else
    leftresp = 'u';
    rightresp = 'i';
%     badresp = 'x';
end

%---------------------------------------------------------------
%% 'READ data from recognitionNewOLD'
%---------------------------------------------------------------

file = dir([outputPath '/' subjectID '_recognitionNewOld_results' num2str(sessionNum) '*.txt']);
fid = fopen([outputPath '/' sprintf(file(length(file)).name)]);
data = textscan(fid, '%d %d %s %d %d %d %d') ;% these contain everything from the recognitionNewOld
fclose(fid);

shuffledlistInd = data{2}; % the ABC index of the stimuli (old and then new)
stimName = data{3}; % the name of the stimuli (including the .jpg)
isOld = data{4}; % is the item old (1) or new (0)
SubAnsOld = data{5}; % the subject's answer: old (1) or new (0)
bidInd = data{6};
isBeep = data{7};

%---------------------------------------------------------------
%% 'SHUFFLE the stimuli that the subject thought were old, for the goNoGo recognition task'
%---------------------------------------------------------------

oldStimLoc = find(SubAnsOld|isOld);
stimIndABC = shuffledlistInd(oldStimLoc);
oldStimName = stimName(oldStimLoc);
oldIsOld = isOld(oldStimLoc);
oldIsBeep = isBeep(oldStimLoc);
oldBidInd = bidInd(oldStimLoc);
numStimuli = length(oldStimLoc);

stimOrder = Shuffle(1:length(oldStimLoc));


%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------
imgArrays = cell(1, numStimuli);
for i = 1:numStimuli
    if oldIsOld(i) == 1
        imgArrays{i} = imread([mainPath '/stim/' oldStimName{i}]);
    else
        imgArrays{i} = imread([mainPath '/stim/recognitionNew/' oldStimName{i}]);
    end
end

% Stack size and location
sizeFactor = 1;
stackH= sizeFactor*size(imgArrays{1},1);
stackW= sizeFactor*size(imgArrays{1},2);
rect = [xcenter-stackW/2 ycenter-stackH/2 xcenter+stackW/2 ycenter+stackH/2];

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1 = fopen([outputPath '/' subjectID '_recognitionGoNoGo' num2str(sessionNum) '_' timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\torder\tstimName\titemIndABC\tbidInd\truntrial\tisOld?\tsubjectAnswerIsOld\tisBeep?\tsubjectAnswerIsBeep\tonsettime\tresp_choice\tRT\n'); %write the header line
% Open txt file to write the subject's answers (Beep \ no beep)
fid2 = fopen([outputPath '/' subjectID '_recognitionGoNoGo_results' num2str(sessionNum) '_' date '.txt'], 'a');

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, 40);
% if sessionNum == 1
%     CenterText(w,'Part 7:',white, 0,-500);
% else
%     CenterText(w,'PART 4:', white,0,-500);
% end
% 
% CenterText(w,'Please think back to the lengthy task you completed with the beeps.',white, 0, -400);
% CenterText(w,'You will NOT hear any beeps during this part of the experiment.',white, 0, -300);
% 
% if order == 1
%     CenterText(w,'Press `u` if you heard a beep when this item was presented.', white,0,-50);
%     CenterText(w,'Press `i` if there was no beep when this item was presented.', white, 0,50);
%     
% else
%     CenterText(w,'Press `u` if there was no beep when this item was presented.', white,0,-50);
%     CenterText(w,'Press `i` if you heard a beep when this item was presented.', white, 0,50);
% end
% 
% CenterText(w,'Please press any key to continue.', green,0,300);
% HideCursor; % Make comment for debugging
% Screen('Flip', w);

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
end; % end if test_comp == 1
DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected  

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
subjectAnswerIsBeep = zeros(1, numStimuli);
    
runStart = GetSecs;

for trial = 1:numStimuli
    ind = stimOrder(trial);
    
    colorright = white;
    colorleft = white;
    
    %-----------------------------------------------------------------
    % display image
    % self-paced; next image will only show after response
    
    Screen('PutImage',w,imgArrays{ind},rect);
    Screen('TextSize',w, 40);
    
%     if order==1
%         Screen('DrawText', w, 'Beep', xcenter-400,ycenter+300, white);
%         Screen('DrawText', w, 'No Beep', xcenter+400, ycenter+300, white);
%     else
%         Screen('DrawText', w, 'No Beep', xcenter-400, ycenter+300, white);
%         Screen('DrawText', w, 'Beep', xcenter+400, ycenter+300, white);
%     end
    
    if order==1
        if test_comp == 1
        CenterText(w,'left - Beep',colorleft,-250,300);
        CenterText(w,'right - No Beep',colorright,250,300);            
        else
        CenterText(w,'u - Beep',colorleft,-250,300);
        CenterText(w,'i - No Beep',colorright,250,300);
        end
    else
        if test_comp == 1
        CenterText(w,'left - No Beep',colorleft,-250,300);
        CenterText(w,'right - Beep',colorright,250,300);            
        else
        CenterText(w,'u - No Beep',colorleft,-250,300);
        CenterText(w,'i - Beep',colorright,250,300);
        end  
    end

    Screen(w,'Flip'); 
    StimOnset = GetSecs;
    
    KbQueueStart;
    %-----------------------------------------------------------------
    % get response
    
    
    noresp=1;
    while noresp
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck(-1);
        
        if keyIsDown && noresp
            findfirstPress = find(firstPress);
            respTime = firstPress(findfirstPress(1))-StimOnset;
            tmp = KbName(findfirstPress);
            if ischar(tmp)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                tmp = char(tmp);
            end
            response = tmp(1);
            if response == leftresp || response == rightresp
            noresp = 0;
            end
            
        end % end if keyIsDown && noresp
        
    end % end while noresp
    
    
    
    %-----------------------------------------------------------------
 
    % determine what bid to highlight and write the subject's response to
    % the subjectAnswerIsBeep array
    if order ==1
        switch response
            case leftresp
                colorleft = green;
                subjectAnswerIsBeep(trial) = 1;
            case rightresp
                colorright = green;
        end
    else % order == 2
        switch response
            case leftresp
                colorleft = green;
            case rightresp
                colorright = green;
                subjectAnswerIsBeep(trial) = 1;
        end
    end % end if order == 1
    
    
    %-----------------------------------------------------------------
    % redraw text output with the appropriate colorchanges
    Screen('PutImage',w,imgArrays{ind},rect);
    Screen('TextSize',w, 40);
%     if order==1
%         Screen('DrawText', w, 'Beep', xcenter-400,ycenter+300, colorleft);
%         Screen('DrawText', w, 'No Beep', xcenter+400, ycenter+300, colorright);
%     else
%         Screen('DrawText', w, 'No Beep', xcenter-400, ycenter+300, colorleft);
%         Screen('DrawText', w, 'Beep', xcenter+400, ycenter+300, colorright);
%     end
    
    if order==1
        if test_comp == 1
        CenterText(w,'left - Beep',colorleft,-250,300);
        CenterText(w,'right - No Beep',colorright,250,300);            
        else
        CenterText(w,'u - Beep',colorleft,-250,300);
        CenterText(w,'i - No Beep',colorright,250,300);
        end
    else
        if test_comp == 1
        CenterText(w,'left - No Beep',colorleft,-250,300);
        CenterText(w,'right - Beep',colorright,250,300);            
        else
        CenterText(w,'u - No Beep',colorleft,-250,300);
        CenterText(w,'i - Beep',colorright,250,300);
        end  
    end
    
    Screen(w,'Flip');
    WaitSecs(0.5);
    
    %-----------------------------------------------------------------
    % show fixation ITI
    Screen('TextSize',w, 60);
    Screen('DrawText', w, '+', xcenter, ycenter, white);
    Screen(w,'Flip');
    WaitSecs(1);
    
    %---------------------------------------------------------------
    %% 'Write to output file'
    %---------------------------------------------------------------
        fprintf(fid1,'%s\t%d\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%s\t%d\n', subjectID, order, oldStimName{ind}, stimIndABC(ind), oldBidInd(ind), trial, oldIsOld(ind), SubAnsOld(oldStimLoc(ind)), oldIsBeep(ind), subjectAnswerIsBeep(trial), StimOnset-runStart, response, respTime);
    fprintf(fid2,'%d\t%d\t%s\t%d\t%d\t%d\t%d\t%d\n', trial, stimIndABC(ind), oldStimName{ind}, oldIsOld(ind), SubAnsOld(oldStimLoc(ind)), oldIsBeep(ind), subjectAnswerIsBeep(trial), oldBidInd(ind));    
    KbQueueFlush;
    
end % end for trial = 1:numStimuli

fclose(fid1);
fclose(fid2);


% Save variables to mat file
outfile = strcat(outputPath,'/', sprintf('%s_recognitionGoNoGo_%s.mat',subjectID, timestamp));

% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;

run_info.script_name = mfilename;
clear imgArrays;
save(outfile);

if test_comp == 1
    if sessionNum == 1    
        Screen('TextSize',w, 40);
        CenterText(w,'Thank you! This part is done.', white,0,0);
        Screen(w,'Flip');
    else
        
        Screen('TextSize',w, 40);
        CenterText(w,'Thank you!', white,0,0);
        Screen(w,'Flip');
    end
else
    % End of session screen
    Screen('TextSize',w, 40);
    CenterText(w,'Thank you!', green,0,0);
    CenterText(w,'The experiment is over.', white,0,-100);
    CenterText(w,'Please call the experimenter.', white,0,-200);
    Screen(w,'Flip');
end

WaitSecs(4);

toc
ShowCursor;
Screen('CloseAll');


% end % end function