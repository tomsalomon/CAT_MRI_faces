% function responseToSnacks(subjectID,mainPath,order,sessionNum)

% function responseToSnacks(subjectID,mainPath,order,sessionNum)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created by Rotem Botvinik July 2015 ===============
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs the trained stimuli for scanning fMRI to compare
% activations and representations of the stimuli before and after the
% training.
% fixed ISI = 7
% each image is represented for 2 secs, and then 7 secs of fixation cross


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'stopGoList_allstim_order%d.txt', order --> Created by the 'sortBdm_Israel' function
%    misc\chocolate.mat  (in which there is a vector named 'chocolate' in
%    which there are 0s and 1s whether each item is chocolate or not
%    (ordered by abc od item names)

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% [outputPath '/' subjectID '_responseToSnacks_session' num2str(sessionNum) '_' representationSession '_' timestamp '.txt']


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% subjectID = 'testMRI';
% order = 1;
% test_comp = 1;
% sessionNum = 1;
% mainPath = 'D:\Rotem\Dropbox\Rotem\experiments\BMI_MRI_snacks_40\BMI_MRI_snacks_40';


clear all

tic

rng shuffle

% =========================================================================
% Get input args and check if input is ok
% =========================================================================

oksessionNum = [1 2 3];
okComputer = [0 1 2 3 4 5];
okOrder = [1 2];
okBeforeAfter = [1 2];
okChocolateOrNot = [1 2];

subjectID = input('Subject code: ','s');
while isempty(subjectID)
    disp('ERROR: no value entered. Please try again.');
    subjectID = input('Subject code:','s');
end
% order number (same across all tasks\runs for a single subject. Should be
% counterbalanced between 1,2 across subjects)

order = input('Enter order number (1,2 ; this should be counterbalanced across subjects): ');
while isempty(order) || sum(okOrder==order)~=1
    disp('ERROR: input must be 1 or 2 . Please try again.');
    order = input('Enter order number (1,2 ; this should be counterbalanced across subjects): ');
end

sessionNum = input('Enter session number (1 if first for this subject): ');
while isempty(sessionNum) || sum(oksessionNum==sessionNum)~=1
    disp('ERROR: input must be 1 or 2 or 3 . Please try again.');
    sessionNum = input('Enter session number (1 if first for this subject): ');
end

beforeAfter = input('Is it the representation before (1) or after (2) training?: ');
while isempty(beforeAfter) || sum(okBeforeAfter==beforeAfter)~=1
    disp('ERROR: input must be 1 or 2 . Please try again.');
    beforeAfter = input('Is it the representation before (1) or after (2) training?: ');
end

runNum = input('Enter the number of this items representation run: ');

chocolateOrNot = input('Do you want to count chocolates (1) or non-chocolates?(2): ');
while isempty(chocolateOrNot) || sum(okChocolateOrNot==chocolateOrNot)~=1
    disp('ERROR: input must be 1 or 2 . Please try again.');
    chocolateOrNot = input('Do you want to count chocolates (1) or non-chocolates?(2): ');
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
switch test_comp
    case 0
        mainPath = '~\Documents\Boost_Short\Output';
    case 1
        mainPath = '/Users/schonberglab_laptop1/Documents/Rotem/BMI_MRI_snacks_40';
    case 2
        mainPath = 'dropbox\trainedInhibition\Boost_Israel';
    case 3
        mainPath = 'D:\Rotem\Dropbox\Rotem\experiments\BMI_MRI_snacks_40\BMI_MRI_snacks_40';
    case 4
        mainPath = '/Users/schonberglabimac1/Documents/BMI_MRI_snacks_40';
    case 5
        mainPath = '/Users/schonberglab_laptop1/Documents/Rotem/BMI_MRI_snacks_40';
end % end switch

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

sizeFactor = 0.8;
stimW = 576*sizeFactor;
stimH = 432*sizeFactor;
rect = [xcenter-stimW/2 ycenter-stimH/2 xcenter+stimW/2 ycenter+stimH/2];


% % Set the colors
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
% green = [0 255 0];

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
if chocolateOrNot == 1
    Instructions = dir([mainPath '/Instructions/functional_response_to_snacks_chocolate.JPG' ]);
else
    Instructions = dir([mainPath '/Instructions/functional_response_to_snacks_notchocolate.JPG' ]);
end
Instructions_image = imread([mainPath '/Instructions/' Instructions(1).name]);

%---------------------------------------------------------------
%% 'GLOBAL VARIABLES'
%---------------------------------------------------------------
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',min,'m'];

%---------------------------------------------------------------
%%   'PRE-TRIAL DATA ORGANIZATION'
%---------------------------------------------------------------

%   'Reading in the sorted BDM list - defines which items should be shown'
% - - - - - - - - - - - - - - -
file = dir([outputPath '/' subjectID '_stopGoList_trainingstim.txt']);
fid = fopen([outputPath '/' sprintf(file(length(file)).name)]);
vars = textscan(fid, '%s %d %d %f %d') ;% these contain everything from the sortbdm
fclose(fid);

% SHUFFLE the stimuli that the subject thought were old, for the goNoGo recognition task
stimNames = vars{1};
[shuff_names,shuff_ind] = Shuffle(stimNames);
bidIndex = vars{3};
shuff_bidIndex = bidIndex(shuff_ind);
numStimuli = length(stimNames);

%   'Reading in the sorted BDM list - for all the stimNames to rightly shuffle the chocolate matrix'
% - - - - - - - - - - - - - - -
file = dir([outputPath '/' subjectID sprintf('_stopGoList_allstim_order%d.txt', order)]);
fid2 = fopen([outputPath '/' sprintf(file(length(file)).name)]);
vars2 = textscan(fid2, '%s %d %d %f %d') ;% these contain everything from the sortbdm
fclose(fid2);
allStimNames = vars2{1};
[ABCallStimNames, ABCind] = sort(allStimNames);

% read the chocolate/not chocolate matrix
load([mainPath '/Misc/chocolate.mat']);
chocolate(ABCind) = chocolate;
chocolate = chocolate(shuff_bidIndex);

%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------
imgArrays = cell(1, numStimuli);
for ind = 1:numStimuli
    imgArrays{ind} = imread([mainPath '/Stim/' shuff_names{ind}],'bmp');
end

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------
switch beforeAfter
    case 1
        representationSession = 'before';
    case 2
        representationSession = 'after';
end

if chocolateOrNot ==1
    fid1 = fopen([outputPath '/' subjectID '_responseToSnacks_session' num2str(sessionNum) '_' representationSession '_chocolates_' timestamp '.txt'], 'a');
    fprintf(fid1,'subjectID\torder\trun\tbefore_or_after\tsession(visit)\titemName\tbidInd\tisChocolate?\tonsettime\tfixationTime\n'); %write the header line
else
    fid1 = fopen([outputPath '/' subjectID '_responseToSnacks_session' num2str(sessionNum) '_' representationSession '_notChocolates_' timestamp '.txt'], 'a');
    fprintf(fid1,'subjectID\torder\trun\tbefore_or_after\tsession(visit)\titemName\tbidInd\tisChocolate?\tonsettime\tfixationTime\n'); %write the header line
end

%---------------------------------------------------------------
%% create matrices before loop
%---------------------------------------------------------------
actual_onset_time = zeros(numStimuli,1);
fixationTime = zeros(1,numStimuli);
ISI = 7;
stimLength = 2; % the length of each stimulus presentation
onsetInterval = ISI + stimLength;
lastOnset = (numStimuli-1) * onsetInterval;
onsetlist = 0:onsetInterval:lastOnset;


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

%   baseline fixation cross
% - - - - - - - - - - - - -
prebaseline = GetSecs;
% baseline fixation - currently 10 seconds = 4*Volumes (2.5 TR)
baseline_fixation_dur = 2; % Need to modify based on if first few volumes are saved or not
while GetSecs < prebaseline+baseline_fixation_dur
    %    Screen(w,'Flip', anchor);
    CenterText(w,'+', white,0,0);
    Screen('TextSize',w, 60);
    Screen(w,'Flip');
    
end
postbaseline = GetSecs;
baseline_fixation = postbaseline - prebaseline;

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------

runStart = GetSecs;

% for stimInd = 1:3 % for debugging
for stimInd = 1:numStimuli
    
    %-----------------------------------------------------------------
    % display image
    Screen('PutImage',w,imgArrays{stimInd},rect);
    % Screen(w,'Flip');
    image_start_time = Screen('Flip',w,runStart + onsetlist(stimInd)); % display an image each
    actual_onset_time(stimInd,1) = image_start_time - runStart + baseline_fixation_dur;
    % WaitSecs(2); % display each image for 2 seconds
    
    
    %-----------------------------------------------------------------
    % show fixation ITI
    Screen('TextSize',w, 60);
    Screen('DrawText', w, '+', xcenter, ycenter, white);
    Screen('Flip',w,runStart+onsetlist(stimInd)+stimLength);
    fixationTime(stimInd) = GetSecs - runStart + baseline_fixation_dur;
    % WaitSecs(5);
    
    %---------------------------------------------------------------
    %% 'Write to output file'
    %---------------------------------------------------------------
    fprintf(fid1,'%s\t %d\t %d\t %s\t %d\t %s\t %d\t %d\t %f\t %f\t\n', subjectID, order, runNum, representationSession, sessionNum, shuff_names{stimInd}, shuff_bidIndex(stimInd), chocolate(stimInd), actual_onset_time(stimInd,1),fixationTime(stimInd));
    
end % end for stimInd = 1:numStimuli

fclose(fid1);
WaitSecs(ISI); % for the last fixation to last like the ones before

% ending screen
Screen('TextSize',w, 40);
CenterText(w,'Thank you!', white,0,0);
Screen(w,'Flip');


% if test_comp == 1
%     if sessionNum == 1
%         Screen('TextSize',w, 40);
%         CenterText(w,'Thank you! This run is done.', white,0,0);
%         Screen(w,'Flip');
%     else
%
%         Screen('TextSize',w, 40);
%         CenterText(w,'Thank you!', white,0,0);
%         Screen(w,'Flip');
%     end
% else
%     % End of session screen
%     Screen('TextSize',w, 40);
%     CenterText(w,'Thank you!', green,0,0);
%     CenterText(w,'The experiment is over.', white,0,-100);
%     CenterText(w,'Please call the experimenter.', white,0,-200);
%     Screen(w,'Flip');
% end

WaitSecs(3);

toc

ShowCursor;
Screen('CloseAll');

% calculate chocolate information
if chocolateOrNot == 1
    howManyChocolateItems = sum(chocolate);
    fprintf('There were %d items with chocolate in this run\n',howManyChocolateItems);
    subjectAnswerHowManyChocolates = input('How many items with chocolate did the subject count?: ');
else
    howManyNotChocolateItems = sum(chocolate==0);
    fprintf('There were %d items without chocolate in this run\n',howManyNotChocolateItems);
    subjectAnswerHowManyNotChocolates = input('How many items without chocolate did the subject count?: ');
end

% Save variables to mat file
outfile = strcat(outputPath,'/', sprintf('%s_resopnseToSnacks_session_%d_%s_run_%d_%s.mat',subjectID,sessionNum,representationSession,runNum,timestamp));

% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;

run_info.script_name = mfilename;
clear imgArrays;
save(outfile);


% end % end function