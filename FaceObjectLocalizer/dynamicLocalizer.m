%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                   %%%
%%% Dynamic localizer %%%
%%%                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
% Screen('Preference', 'SkipSyncTests', 1);

%% Ensure the generation of random numbers.
% http://www.mathworks.com/help/matlab/math/why-do-random-numbers-repeat-after-startup.html
rng('shuffle');

%%   'timestamp'
% - - - - - - - - - - - - - - - - -
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

%% Experiment parmeters
objectsDir      = 'dynamicObjects';
facesDir        = 'dynamicFaces';
rootDir         = pwd();
stimuliPerBlock = 16;
fixationMovie   = [ pwd() '/fix3.avi' ];
trialDuration   = 1; % Secs.
rootDir         = pwd();

%{
%% Record the subject ID using a dialog window
dlg_title   = 'Experiment settings';
prompt      = { 'SubjectID:', 'Run num', 'Block duration' };
num_lines   = 1;
def         = {'Sub_0', '1', '16' };
answer      = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return;
end

subjectID       = answer{1};
numOfDesign     = str2num(answer{2});
blockDuration   = str2num(answer{3});
%}

blockDuration=16;

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

okRun = [1 2 3];
which_run = input('Enter run 1 or 2. 3 if you want demo: ');
while isempty(which_run) || sum(okRun == which_run) ~=1
    disp('ERROR: input must be 1 or 2. Please try again.');
    which_run = input('Enter run 1, 2 or 3');
end
numRun = which_run;

numOfDesign = numRun; % set design to 1 or 2 according to the run num

%% 
if blockDuration == 16
    trialDuration   = 1; % Secs.
    stimDisplayTime = 0.9; % Secs.
    totalBlockTime  = stimuliPerBlock * trialDuration;
    dummyScanTime   = 6;  % for 16 seconds localizer - 6 seconds dummy scans 
elseif blockDuration == 15
    trialDuration   = 0.9375; % Secs.
    stimDisplayTime = 0.85; % Secs.
    totalBlockTime  = stimuliPerBlock * trialDuration;
    dummyScanTime   = 10;  % for 15 seconds localizer - 10 seconds dummy scans
else
    errordlg('Invalid block duration ! valid values are 15 or 16.', 'Wrong block duration', 'modal');
    error('Invalid block duration ! valid values are 15 or 16.');
end

displayOrder    = getDesignByNumber(numOfDesign);
   
%% set frame rate and durations
whichScreen     = 0;
theFrameRate    = Screen('FrameRate', whichScreen);
fixDur          = round(0.750 * theFrameRate);
snapshotDur     = round(1 * theFrameRate);
btwDur          = round(0.500 * theFrameRate);
responseDur     = round(0.200 * theFrameRate);
breakDur        = 300;
bgcolor         = [ 127 127 127 ]; % background color = black
fcolor          = [ 255 255 255 ]; % forground color = white
fgpreDur        = round(1.500 * theFrameRate);
textColor       = 255; % Psychtoolbox treats this as [ 255 255 255 ].

% Set rects
screenRect              = Screen(0, 'rect');
frameRect               = [0 0 640 480];
centerPosn              = CenterRect(frameRect, screenRect);
largeRect               = [0 0 1000 750];
largecenterposition     = CenterRect(largeRect, screenRect);
centerPosn1             = CenterRect(largeRect, screenRect);
window                  = Screen(0,'OpenWindow', bgcolor , screenRect, 32);

%% Create fixation and non-fixation displays
fixation = Screen(window,'OpenOffscreenWindow', bgcolor, frameRect);
Screen(fixation, 'FillOval', fcolor, CenterRect([0 0  8  8], frameRect));

nofixation = Screen(window,'OpenOffscreenWindow', bgcolor, frameRect);
Screen(nofixation, 'FillOval', bgcolor, CenterRect([0 0  8  8], frameRect));

%% Load movies
stimBlocks = randomizeDynamicAndAdd1Back(displayOrder, stimuliPerBlock, window, bgcolor, largeRect, objectsDir, facesDir);

%% 
HideCursor;

%% Results variable initialization.
numOfTrials = length(displayOrder);
% create an empty cell of trialNumTotal size + 1
ResultsArray=cell(numOfTrials + 1, 6);
% write header of cell to first row
ResultsArray(1,:) = { 'trial','time','stimulus', 'RT', 'KeyPressed', 'Is correct' };
resultsArrayLogSize = 1; % Logical size (number of actual elements) in ResultsArray.

%% Play a movie to enable faster loading time during the experiments.
try 
    [movie, movieduration, fps] = Screen('OpenMovie', window, fixationMovie); %open the movie
    
    Screen('PlayMovie', movie, 1); %start playing the movie
    
    % Movie playback variables. Do not delete any of them.
    movietexture    = 0;
    reactiontime    = -1;
    lastpts         = 0;
    onsettime       = -1;
    rejecttrial     = 0;
    timeOfEvent     = 0;
    
    % Documentation in : DetectionRTInVideoDemo.m (psychtoolbox demos
    % folder).
    while(movietexture>=0 && reactiontime==-1)
        [movietexture, pts] = Screen('GetMovieImage', window, movie, 0);
        if (movietexture>0)
            Screen('DrawTexture', window, movietexture);
            vbl=Screen('Flip', window);
            if (onsettime==-1 && pts >= timeOfEvent)
                onsettime = vbl;
                if (pts - lastpts > 1.5*(1/fps))
                    rejecttrial=1; % Ignore this !! but don't delete it.
                end;
            end;
            
            lastpts=pts;
            
            Screen('Close', movietexture);
            movietexture=0;
        end;
    end
    
    % Playback loop exited. Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie:
    Screen('CloseMovie', movie);
    
catch %display error in case the movie cannot be displayed
    psychrethrow(psychlasterror);
    sca;
end %try

%% Waiting for 'trigger' to begin
clearit = Screen(window,'OpenOffscreenWindow', bgcolor, frameRect);
Screen(window,'TextSize', 30);
CenterText(window,'Press when you see a replay of the previous clip', textColor,0,-60);
Screen(window,'Flip');
WaitSecs(3)
CenterText(window,'Press when you see a replay of the previous clip', textColor,0,-60);
CenterText(window,'Please Wait. Waiting for triger...', textColor,0,0);
Screen(window,'Flip');

startKey= KbName('t'); %% a key to start the experiment
% startKey= KbName('space'); %% a key to start the experiment

% wait for keyboard before continuing.
while ( CharAvail )
    [tmpChar, junk]=GetChar;
end;  %% clear keypress buffer
[avail, secs, keyCode] = KbCheck;
while (~keyCode(startKey))
    [avail, secs, keyCode] = KbCheck;
end;
while ( CharAvail )
    [tmpChar, junk]=GetChar;
end;  %% clear keypress buffer

%% Play dummy trial (fixation) for ~6 seconds
dummyTimer = GetSecs();
Screen('DrawTexture', window, fixation);
Screen(window,'Flip');

pause(dummyScanTime-0.015);
% pause(5.985);

Screen('DrawTexture', window, nofixation);
Screen(window,'Flip');
dummyElapsedTime = GetSecs() - dummyTimer

%% Main display loop.
outerLoopTimeOffset = 0;

allBlocksTimer = GetSecs();

for BlockNum=1 : length(stimBlocks)
    timer = GetSecs();
    
    resultWriteInd  = resultsArrayLogSize + 1;
    stimType        = stimBlocks(BlockNum).type;
    startIdx        = resultWriteInd;
    endIdx          = resultWriteInd + stimuliPerBlock -1;
    type            = stimBlocks(BlockNum).type;
    oneBackIndices  = stimBlocks(BlockNum).oneBackIndices;
    stimNames       = stimBlocks(BlockNum).filenames;
    fullStimNames   = stimBlocks(BlockNum).fullFilenames;
    
    
    if strcmp(stimType, 'fixation') 
        disp('fixation type trial');
        outerLoopTimeOffset = ((BlockNum - 1) * stimuliPerBlock * trialDuration) - (GetSecs() - allBlocksTimer)
    end
    
    ResultsArray( startIdx:endIdx, :) = displayDynamicStimBlockMRI(nofixation, window, centerPosn, centerPosn1, ... 
        fixation, oneBackIndices, stimNames, type, fullStimNames, trialDuration, outerLoopTimeOffset, totalBlockTime, stimDisplayTime,allBlocksTimer,BlockNum);
        
    resultsArrayLogSize = resultsArrayLogSize + stimuliPerBlock;
    
    outerLoopTimeOffset = (trialDuration * stimuliPerBlock) - (GetSecs() - timer)
end

'All Blocks', GetSecs() - allBlocksTimer

%% End of experiment - writing results.
% Ensure that the names of the stimuli are strings and not cells.
for idx = 1:length(ResultsArray(:))
    if iscell(ResultsArray{idx})
        ResultsArray(idx) = ResultsArray{idx};
    end
end

outputPath='./../Output/';
logFilename = strcat(outputPath, sprintf('%s_faceLocalizer_run_%d_%s.csv',subjectID,numOfDesign,timestamp));


cell2csv(logFilename, ResultsArray);
Screen('CloseAll');
close all;