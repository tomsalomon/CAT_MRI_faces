% function responseToStimuli(subjectID,mainPath,order,sessionNum)

% function responseToStimuli(subjectID,mainPath,order,sessionNum)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created by Rotem Botvinik July 2015 ===============
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs the trained stimuli for scanning fMRI to compare
% activations and representations of the stimuli before and after the
% training.
% fixed ISI = 8
% each image is represented for 2 secs, and then 6 secs of fixation cross
% The "dummy" task is to count either "one" items or "several" items (Does
% the item contain one or several items inside a new closed bag?)


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'stopGoList_allstim_order%d.txt', order --> Created by the 'sortBdm_Israel' function
%    Misc\oneSeveral.mat  (in which there is a vector named 'oneSeveral' in
%    which there are 1s and 2s whether each item is 'one' (1) or 'several'
%    (2)(ordered by abc of item names)

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% [outputPath '/' subjectID '_responseToStimuli_session' num2str(sessionNum) '_' representationSession '_' timestamp '.txt']


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
% Screen('Preference', 'SkipSyncTests', 1);
% =========================================================================
% Get input args and check if input is ok
% =========================================================================

oksessionNum = [1 2 3];
okComputer = [0 1 2 3 4 5];
okOrder = [1 2];
okBeforeAfter = [1 2];

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

sessionNum=2;
% sessionNum = input('Enter session number (1 if first for this subject): ');
% while isempty(sessionNum) || sum(oksessionNum==sessionNum)~=1
%     disp('ERROR: input must be 1 or 2 or 3 . Please try again.');
%     sessionNum = input('Enter session number (1 if first for this subject): ');
% end

% beforeAfter = input('Is it the representation before (1) or after (2) training?: ');
% while isempty(beforeAfter) || sum(okBeforeAfter==beforeAfter)~=1
%     disp('ERROR: input must be 1 or 2 . Please try again.');
%     beforeAfter = input('Is it the representation before (1) or after (2) training?: ');
% end

runNum = input('Enter the number of this run: ');

% decide whether it's a "male" counting run or a "female" counting run
switch order
    case 1
        if mod(runNum,2)==1 % this is an odd runNum
        response_to_male = 1;   
        else % this is a pair runNum
        response_to_male = 0;   
        end
    case 2
        if mod(runNum,2)==1 % this is an odd runNum
        response_to_male = 0;    
        else % this is a pair runNum
        response_to_male = 1;     
        end
end % end switch order
  
okEyetracker = [1 0];
ask_if_want_eyetracker = input('Do you want eyetracking (1 - yes, 0 - no): ');
    while isempty(ask_if_want_eyetracker) || sum(okEyetracker == ask_if_want_eyetracker) ~=1
        disp('ERROR: input must be 1 or 0. Please try again.');
        ask_if_want_eyetracker = input('Do you want eyetracking (1 - yes, 0 - no): ');
    end
use_eyetracker=ask_if_want_eyetracker; % set to 1/0 to turn on/off eyetracker functions

% =========================================================================
% set the computer and path
% =========================================================================

% test_comp = input('Which computer are you using? 5 MacBookPro1, 4 new mac, 3 Rotem_PC, 2 Toms_iMac, 1 MRI, 0 if testooom: ');
% while isempty(test_comp) || sum(okComputer==test_comp)~=1
%     disp('ERROR: input must be 0,1,2,3,4 or 5. Please try again.');
%     test_comp = input('Which computer are you using? 5 MacBookPro1, 4 new mac, 3 Rotem_PC, 2 Toms_iMac, 1 MRI, 0 if testooom: ');
% end
 test_comp = 1; % 1 for MRI
% Set main path

mainPath = pwd;


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
if response_to_male == 1
    Instructions = dir([mainPath '/Instructions/fmri_response_to_stimuli_male.JPG' ]);
else
    Instructions = dir([mainPath '/Instructions/fmri_response_to_stimuli_female.JPG' ]);
end
Instructions_image = imread([mainPath '/Instructions/' Instructions(1).name]);

%---------------------------------------------------------------
%% 'GLOBAL VARIABLES'
%---------------------------------------------------------------
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',min,'m'];
%-----------------------------------------------------------------
%% Initializing eye tracking system %
%-----------------------------------------------------------------
% use_eyetracker=1; % set to 1/0 to turn on/off eyetracker functions
if use_eyetracker
    dummymode=0;
    
    % STEP 2
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(w);
    % Disable key output to Matlab window:
    
    el.backgroundcolour = black;
    el.backgroundcolour = black;
    el.foregroundcolour = white;
    el.msgfontcolour    = white;
    el.imgtitlecolour   = white;
    el.calibrationtargetcolour = el.foregroundcolour;
    EyelinkUpdateDefaults(el);
    
    % STEP 3
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end;
    
    [v,ELversion]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', ELversion );
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');
    
    % open file to record data to
    edfFile='Res2stim.edf';
    Eyelink('Openfile', edfFile);
    
    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    
    %     % STEP 5
    %     % start recording eye position
    %     Eyelink('StartRecording');
    %     % record a few samples before we actually start displaying
    %     WaitSecs(0.1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Finish Initialization %
    %%%%%%%%%%%%%%%%%%%%%%%%%
end

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

% %   'Reading in the sorted BDM list - for all the stimNames to rightly shuffle the oneSeveral matrix'
% % - - - - - - - - - - - - - - -
% file = dir([outputPath '/' subjectID sprintf('_stopGoList_allstim_order%d.txt', order)]);
% fid2 = fopen([outputPath '/' sprintf(file(length(file)).name)]);
% vars2 = textscan(fid2, '%s %d %d %f %d') ;% these contain everything from the sortbdm
% fclose(fid2);
% allStimNames = vars2{1};
% [ABCallStimNames, ABCind] = sort(allStimNames);
% 
% % read the oneSeveral matrix
% load([mainPath '/Misc/oneSeveral.mat']);
% oneSeveral(ABCind) = oneSeveral;
% oneSeveral = oneSeveral(shuff_bidIndex);

%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------
imgArrays = cell(1, numStimuli);
for ind = 1:numStimuli
    imgArrays{ind} = imread([mainPath '/Stim/' shuff_names{ind}]);
end

sizeFactor = 1;
stimW = size(imgArrays{1},2)*sizeFactor;
stimH = size(imgArrays{1},1)*sizeFactor;
rect = [xcenter-stimW/2 ycenter-stimH/2 xcenter+stimW/2 ycenter+stimH/2];

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------
        representationSession = 'follow_up';


if response_to_male ==1
    fid1 = fopen([outputPath '/' subjectID '_responseToStimuli_session' num2str(sessionNum) '_' representationSession '_male_' timestamp '.txt'], 'a');
    fprintf(fid1,'subjectID\torder\trun\tbefore_or_after\tsession(visit)\titemName\tbidInd\tisMale?\tonsettime\tfixationTime\n'); %write the header line
else
    fid1 = fopen([outputPath '/' subjectID '_responseToStimuli_session' num2str(sessionNum) '_' representationSession '_female_' timestamp '.txt'], 'a');
    fprintf(fid1,'subjectID\torder\trun\tbefore_or_after\tsession(visit)\titemName\tbidInd\tisMale?\tonsettime\tfixationTime\n'); %write the header line
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

isMale=zeros(numStimuli,1);
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



%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------

runStart = GetSecs;

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

if use_eyetracker
    % start recording eye position
    %---------------------------
    Eyelink('StartRecording');
    WaitSecs(.05);
    
    %   Eyelink MSG
    % ---------------------------
    % messages to save on each trial ( trial number, onset and RT)
    Eyelink('Message',['SYNCTIME at run start:',GetSecs]); % mark start time in file 
end

% for stimInd = 1:3 % for debugging
for stimInd = 1:numStimuli
    
    %-----------------------------------------------------------------
    % display image
    Screen('PutImage',w,imgArrays{stimInd},rect);
    % Screen(w,'Flip');
    image_start_time = Screen('Flip',w,runStart +baseline_fixation+ onsetlist(stimInd)); % display an image each
    actual_onset_time(stimInd,1) = image_start_time - runStart;
    % WaitSecs(2); % display each image for 2 seconds
    if use_eyetracker && runStart +baseline_fixation+ onsetlist(stimInd)<GetSecs
        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message',['trial ',num2str(stimInd),' stim: ',shuff_names{stimInd},' time:',num2str(GetSecs)]);
    end
    
    %-----------------------------------------------------------------
    % show fixation ITI
    Screen('TextSize',w, 60);
    Screen('DrawText', w, '+', xcenter, ycenter, white);
    fixation_start_time=Screen('Flip',w,runStart+baseline_fixation+onsetlist(stimInd)+stimLength);
    fixationTime(stimInd) = fixation_start_time - runStart;
    % WaitSecs(5);
        if use_eyetracker && runStart +baseline_fixation+ onsetlist(stimInd)<GetSecs
        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message',['ITI fixation cross time:',num2str(GetSecs)]);
        end
    
    current_stim_name=str2double(shuff_names{stimInd}(1:end-4));
    if current_stim_name<2000
    isMale(stimInd)=1;
    end
    
    %---------------------------------------------------------------
    %% 'Write to output file'
    %---------------------------------------------------------------
    fprintf(fid1,'%s\t %d\t %d\t %s\t %d\t %s\t %d\t %d\t %f\t %f\t\n', subjectID, order, runNum, representationSession, sessionNum, shuff_names{stimInd}, shuff_bidIndex(stimInd), isMale(stimInd), actual_onset_time(stimInd,1),fixationTime(stimInd));
    
end % end for stimInd = 1:numStimuli

fclose(fid1);
WaitSecs(ISI); % for the last fixation to last like the ones before

% ending screen
Screen('TextSize',w, 40);
CenterText(w,'Thank you!', white,0,0);
Screen(w,'Flip');

WaitSecs(3);

toc

ShowCursor;
Screen('CloseAll');

if use_eyetracker
    
    %---------------------------------------------------------------
    %%   Finishing eye tracking system %
    %---------------------------------------------------------------
    
    % STEP 7
    %---------------------------
    % finish up: stop recording eye-movements,
    % close graphics window, close data file and shut down tracker
    Eyelink('StopRecording');
    WaitSecs(.1);
    Eyelink('CloseFile');
    
    
    % download data file
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch rdf
        fprintf('Problem receiving data file ''%s''\n', edfFile );
        rdf;
    end

    
    if dummymode==0
        movefile(edfFile,['./Output/', sprintf('%s_resopnseToStimuli_EyeTracking_session_%d_%s_run_%d_%s.edf',subjectID,sessionNum,representationSession,runNum,timestamp)]);
    end;
end

% calculate male-female information
if response_to_male == 1
    howManyOneItems = sum(isMale==1);
    fprintf('There were %d male stimuli in this run\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n',howManyOneItems); % many 'enters' so the subject will not see the answer
    subjectAnswerHowManyMaleStimuli = input('How many male stimuli did the subject count?: ');
else
    howManySeveralItems = sum(isMale==0);
    fprintf('There were %d female stimuli in this run\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n',howManySeveralItems); % many 'enters' so the subject will not see the answer
    subjectAnswerHowManyFemaleStimuli = input('How many female stimuli did the subject count?: ');
end

% Save variables to mat file
outfile = strcat(outputPath,'/', sprintf('%s_resopnseToStimuli_session_%d_%s_run_%d_%s.mat',subjectID,sessionNum,representationSession,runNum,timestamp));

% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;

run_info.script_name = mfilename;
clear imgArrays Instructions_image;
save(outfile);


% end % end function