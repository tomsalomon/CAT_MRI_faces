

% function [block] = script_training_Israel(subjectID,block)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Tom Salomon, September 2014 =====================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs the boost (cue-approach) training session,
% in which the items are shown on the screen while some of them (GO items) are
% paired with a beep. The subject should press a predefined button as fast
% as possible after hearing the beep.
% This session is composed of total_num_runs_training number of runs.
% After two runs there is a short break. If the subject was bad (less than
% %50 of in-time button pressing out of go trials in these two runs) there
% is a request to press faster (a feedback just for keeping the subjects
% aware if their responses shows they are not).
%
% % % Important audio player note:
% ------------------------------------------
% Some computers do not run the PTB audio functions correctly. therefore,
% this function can also use MATLAB built-in play(Audio) function. however,
% this function had poor time accuracy, so only use it if PTB is not working
% well.
%In order to switch between PTB or MATLAB's audio functions, change
%'use_PTB' variable to 1 or 0, respectively

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   ''stopGoList_allstim_order%d.txt', order'
%   ''/Onset_files/train_onset_' num2str(r(1)) '.mat''  where r=1-4
%   all the contents of 'stim/'
%   'Misc/soundfile.mat'
%   'CenterText.m'


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'training_run_' sprintf('%02d',runNum) '_' timestamp '.txt'

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% subjectID = 'BM_9001';
% test_comp = 3;
% order = 1;
% mainPath = 'D:\Rotem\Matlab\Boost_Israel_New_Rotem';
% runInd = 1;
% total_num_runs_training = 4;
% Ladder1IN = 750;
% Ladder2IN = 750;
clear all
tic

% Screen('Preference', 'SkipSyncTests', 1);

% =========================================================================
% Get input args and check if input is ok
% =========================================================================

oksessionNum = [1 2 3];
okComputer = [0 1 2 3 4 5];
okBlock = [1:8];

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

sessionNum=1; % session number (1 if first for this subject)

% sessionNum = input('Enter session number (1 if first for this subject): ');
% while isempty(sessionNum) || sum(oksessionNum==sessionNum)~=1
%     disp('ERROR: input must be 1 or 2 or 3 . Please try again.');
%     sessionNum = input('Enter session number (1 if first for this subject): ');
% end


% =========================================================================
% set the computer and path
% =========================================================================

% test_comp = input('Which computer are you using? 5 MacBookPro1, 4 new mac, 3 Rotem_PC, 2 Toms_iMac, 1 MRI, 0 if testooom: ');
% while isempty(test_comp) || sum(okComputer==test_comp)~=1
%     disp('ERROR: input must be 0,1,2,3,4 or 5. Please try again.');
%     test_comp = input('Which computer are you using? 5 MacBookPro1, 4 new mac, 3 Rotem_PC, 2 Toms_iMac, 1 MRI, 0 if testooom: ');
% end
test_comp=1; % 5 MacBookPro1, 4 new mac, 3 Rotem_PC, 2 Toms_iMac, 1 MRI, 0 if testooom
% Get block number
mainPath=pwd;

block = input('Which Block are you at: ');
while isempty(block) || sum(okBlock==block)~=1
    disp('ERROR: invalid input. Please try again.');
    block = input('Which Block are you at: ');
end

okEyetracker = [1 0];
ask_if_want_eyetracker = input('Do you want eyetracking (1 - yes, 0 - no): ');
    while isempty(ask_if_want_eyetracker) || sum(okEyetracker == ask_if_want_eyetracker) ~=1
        disp('ERROR: input must be 1 or 0. Please try again.');
        ask_if_want_eyetracker = input('Do you want eyetracking (1 - yes, 0 - no): ');
    end
use_eyetracker=ask_if_want_eyetracker; % set to 1/0 to turn on/off eyetracker functions


% Set the number of run per block
num_runs_per_block = 2;
% Set the index of the first run in the current block
runInd=(block-1)*num_runs_per_block+1;
% Set the total number of in the experiment
total_number_of_runs=16;

%---------------------------------------------------------
%%  'SCRIPT VERSION'
%---------------------------------------------------------
% notes = ('Design developed by Schonberg, Bakkour and Poldrack, inspired by Boynton');
script_name = 'Boost_behavioral_Israel';
script_version='1';
revision_date='11-18-2014';
fprintf('%s %s (revised %s)\n',script_name,script_version,revision_date);

%---------------------------------------------------------------
%%   'GLOBAL VARIABLES'
%---------------------------------------------------------------

outputPath = [mainPath '/Output'];

% essential for randomization
rng('shuffle');

% about timing
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',minutes,'m'];

% about ladders
Step = 50;

% about timing
image_duration = 1; %because stim duration is 1.5 secs in opt_stop
baseline_fixation = 2;
afterrunfixation = 7;

% -----------------------------------------------
%% Load Instructions
% -----------------------------------------------

% Load Hebrew instructions image files
Instructions=dir([mainPath '/Instructions/fmri_training.JPG' ]);
Instructions_name=struct2cell(rmfield(Instructions,{'date','bytes','isdir','datenum'}));
Instructions_image=imread([mainPath '/Instructions/' sprintf(Instructions_name{1})]);

% -----------------------------------------------
%% 'INITIALIZE SCREEN'
% -----------------------------------------------


Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = max(Screen('Screens'));

pixelSize=32;
% [w] = Screen('OpenWindow',screennum,[],[0 0 800 700],pixelSize);% %debugging screensize
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

%   colors
% - - - - - -
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
Green = [0 255 0];

Screen('FillRect', w, black);
Screen('Flip', w);

%   text
% - - - - - -
theFont='Arial';
Screen('TextSize',w,36);
Screen('TextFont',w,theFont);
Screen('TextColor',w,white);

WaitSecs(1);
HideCursor;


%%---------------------------------------------------------------
%%  'FEEDBACK VARIABLES'
%%---------------------------------------------------------------

if test_comp == 1
    blue = 'b';
    yellow = 'y';
    %     %     trigger = KbName('t');
    %     blue = KbName('b');
    %     yellow = KbName('y');
    %     %     green = KbName('g');
    %     %     red = KbName('r');
    %     %     LEFT = [98 5 10];   % blue (5) green (10)
    %     %     RIGHT = [121 28 21]; % yellow (28) red (21)
else
    BUTTON = 98; %[197];  %<
    %RIGHT = [110]; %[198]; %>
end; % end if test_comp == 1

%---------------------------------------------------------------
%%   'PRE-TRIAL DATA ORGANIZATION'
%---------------------------------------------------------------

%   'Reading in the sorted BDM list - defines which items will be GO\NOGO'
% - - - - - - - - - - - - - - -
file = dir([outputPath '/' subjectID '_stopGoList_trainingstim.txt']);
fid = fopen([outputPath '/' sprintf(file(length(file)).name)]);
vars = textscan(fid, '%s %d %d %f %d') ;% these contain everything from the sortbdm
fclose(fid);

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
    
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');
    
    % open file to record data to
    edfFile=['train',num2str(block),'.edf'];
    Eyelink('Openfile', edfFile);
    
    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    WaitSecs(2);
    %     % STEP 5
    %     % start recording eye position
    %     Eyelink('StartRecording');
    %     % record a few samples before we actually start displaying
    %     WaitSecs(0.1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Finish Initialization %
    %%%%%%%%%%%%%%%%%%%%%%%%%
end
% -------------------------------------------------------
%% 'Sound settings'
%%---------------------------------------------------------------

% load('Misc/soundfile.mat');
wave = sin(1:0.25:1000);
freq = 22254;
use_PTB_audio=1; % 1 for PTB audio function or 0 to for matlab's bulit in audio function (use only in case PTB's functions do not work well)

%% With PTB audio player
if use_PTB_audio==1
    nrchannels = size(wave,1);
    deviceID = -1;
    reqlatencyclass = 2; % class 2 empirically the best, 3 & 4 == 2
    InitializePsychSound(1);% Initialize driver, request low-latency preinit:
    % Open audio device for low-latency output:
    pahandle = PsychPortAudio('Open', deviceID, [], reqlatencyclass, freq, nrchannels);
    PsychPortAudio('RunMode', pahandle, 1);
    %Play the sound
    PsychPortAudio('FillBuffer', pahandle, wave);
    PsychPortAudio('Start', pahandle, 1, 0, 0);
    WaitSecs(1);
    % Close the sound and open a new port for the next sound with low latency
    
    PsychPortAudio('Close', pahandle);
    pahandle = PsychPortAudio('Open', deviceID, [], reqlatencyclass, freq, nrchannels);
    PsychPortAudio('RunMode', pahandle, 1);
    PsychPortAudio('FillBuffer', pahandle, wave);
    
    %% Without PTB audio player
elseif use_PTB_audio==0
    Audio = audioplayer(wave,freq);
    %Play the sound
    play(Audio);
    
    WaitSecs(1);
end

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------
KbQueueCreate;
Screen('TextSize',w, 40);

% if block ==1 % if this is the first block, present full instructions
    Screen('PutImage',w,Instructions_image);
% else
%     CenterText(w,'Another run begins now', white, 0,0);
%     CenterText(w,'Press any key to continue', Green, 0,150);
% end

Screen(w,'Flip');
WaitSecs(0.01);

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
        max(keyCode)
        if keyIsDown && keyCode(escapeKey)
            break;
        end
    end
    
    DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected
    
end; % end if test_comp == 1
DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected

WaitSecs(0.01);

Screen('TextSize',w, 60);
CenterText(w,'+', white,0,0);
Screen(w,'Flip');
WaitSecs(2);

KbQueueCreate;
% KbQueueStart;



%---------------------------------------------------------------
%%  'TRIAL PRESENTATION'
%---------------------------------------------------------------
%
%   trial_type definitions:
% - - - - - - - - - - - -
% 11 = High-Value GO
% 12 = High-Value NOGO
% 22 = Low-Value GO
% 24 = Low-Value NOGO


% Setting the size of the variables for the loop
%---------------------------
shuff_names = cell(1,num_runs_per_block);
shuff_ind = cell(1,num_runs_per_block);
bidIndex = cell(1,num_runs_per_block);
shuff_bidIndex = cell(1,num_runs_per_block);
itemnameIndex = cell(1,num_runs_per_block);
shuff_itemnameIndex = cell(1,num_runs_per_block);
trialType = cell(1,num_runs_per_block);
shuff_trialType = cell(1,num_runs_per_block);
Audio_time = cell(1,num_runs_per_block);
respTime = cell(1,num_runs_per_block);
respInTime = cell(1,num_runs_per_block);
keyPressed = cell(1,num_runs_per_block);
Ladder1 = cell(1,num_runs_per_block);
Ladder2 = cell(1,num_runs_per_block);
actual_onset_time = cell(1,num_runs_per_block);
fix_time = cell(1,num_runs_per_block);
fixcrosstime = cell(1,num_runs_per_block);
Ladder1end = cell(1,num_runs_per_block);
Ladder2end = cell(1,num_runs_per_block);
correct = cell(1,num_runs_per_block);
numGoTrials = zeros(1, num_runs_per_block);
mean_RT = cell(1,num_runs_per_block);
bidValues = cell(1,num_runs_per_block);
shuff_bidValues = cell(1,num_runs_per_block);


anchor = GetSecs ; % (before baseline fixation) ;

if use_eyetracker
    % start recording eye position
    %---------------------------
    Eyelink('StartRecording');
    WaitSecs(.05);
end

% for runNum = runInd:runInd+1; % for debugging 2 runs starting with runInd
for runNum = runInd:runInd+num_runs_per_block-1 %this for loop allows all runs in block to be completed
    
    if use_eyetracker
        %   Eyelink MSG
        % ---------------------------
        % messages to save on each trial ( trial number, onset and RT)
        Eyelink('Message', ['SYNCTIME at run ' num2str(runNum) ' start: ',GetSecs]); % mark start time in file
    end
    
    KbQueueFlush;
    
    %   'fac onsets'
    %---------------------------
    r = Shuffle(1:4);
    load(['Onset_files/train_onset_' num2str(r(1)) '.mat']);
    
    %   'Write output file header'
    %---------------------------------------------------------------
    c = clock;
    hr = sprintf('%02d', c(4));
    minutes = sprintf('%02d', c(5));
    timestamp = [date,'_',hr,'h',minutes,'m'];
    
    fid1 = fopen([outputPath '/' subjectID '_training_run_' sprintf('%02d',runNum) '_' timestamp '.txt'], 'a');
    fprintf(fid1,'subjectID\t order\t runNum\t itemName\t onsetTime\t shuff_trialType\t RT\t respInTime\t AudioTime\t response\t fixationTime\t ladder1\t ladder2\t bidIndex\t itemNameIndex\t bidValue\t \n'); %write the header line
    
    
    %   'pre-trial fixation'
    %---------------------------
    
    firstOrSecond = mod(runNum,2);
    
    switch firstOrSecond
        case 1
            prebaseline = GetSecs;
            % baseline fixation - currently 2 seconds = (2 TR)
            while GetSecs < prebaseline + baseline_fixation
                CenterText(w,'+', white,0,0);
                Screen('TextSize',w, 60);
                Screen(w,'Flip');
            end
%         case 0
%             prebaseline = GetSecs;
%             % baseline fixation - currently 2 seconds = (2 TR)
%             while GetSecs < prebaseline + afterrunfixation
%                 CenterText(w,'+', white,0,0);
%                 Screen('TextSize',w, 60);
%                 Screen(w,'Flip');
%             end
    end
    
    
    %   Reading everying from the sorted StopGo file - vars has everything
    %---------------------------
    [shuff_names{runNum},shuff_ind{runNum}] = Shuffle(vars{1});
    
    trialType{runNum} = vars{2};
    shuff_trialType{runNum} = trialType{runNum}(shuff_ind{runNum});
    
    bidIndex{runNum} = vars{3};
    shuff_bidIndex{runNum} = bidIndex{runNum}(shuff_ind{runNum});
    
    bidValues{runNum} = vars{4};
    shuff_bidValues{runNum} = bidValues{runNum}(shuff_ind{runNum});
    
    itemnameIndex{runNum} = vars{5};
    shuff_itemnameIndex{runNum} = itemnameIndex{runNum}(shuff_ind{runNum});
    
    %	pre-allocating matrices
    %---------------------------
    Audio_time{runNum}(1:length(shuff_trialType{runNum}),1) = 999;
    respTime{runNum}(1:length(shuff_trialType{runNum}),1) = 999;
    respInTime{runNum}(1:length(shuff_trialType{runNum}),1) = 999;
    keyPressed{runNum}(1:length(shuff_trialType{runNum}),1) = 999;
    
    %   reading in images
    %---------------------------
    Images = cell(1, length(shuff_names{runNum}));
    for i = 1:length(shuff_names{runNum})
        Images{i} = imread(['stim/',shuff_names{runNum}{i}]);
    end
    
    %   Read in info about ladders
    % - - - - - - - - - - - - - - -
    
    if block==1 && runNum==1 % if this is the very first run of the experiment, start ladders at 750
        Ladder1IN=750;
        Ladder2IN=750;
    else % read the ladders from the previous run's txt file
        last_run=dir(sprintf('%s/%s_training_run_%02d_*.txt',outputPath,subjectID,runNum-1));
        clear last_run_fid last_run_data
        last_run_fid=fopen([outputPath,'/',last_run(end).name]);
        last_run_data=textscan(last_run_fid,'%s %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f','HeaderLines',1);
        last_run_fid=fclose(last_run_fid);
        
        Ladder1IN=last_run_data{12}(end);
        Ladder2IN=last_run_data{13}(end);
    end
    
    Ladder1{runNum}(1,1) = Ladder1IN;
    Ladder2{runNum}(1,1) = Ladder2IN;
    
    %         if runNum == 1
    %             Ladder1{runNum}(1,1) = 750;
    %             Ladder2{runNum}(1,1) = 750;
    %         else runNum == runInd
    %             Ladder1{runNum}(1,1) = Ladder1IN;
    %             Ladder2{runNum}(1,1) = Ladder2IN;
    %         else % runNum > 1
    %             Ladder1{runNum}(1,1) = Ladder1end{runNum-1};
    %             Ladder2{runNum}(1,1) = Ladder2end{runNum-1};
    %             %         tmp2 = dir([outputPath '/' subjectID '_ladders_run_' num2str(runNum - 1) '.txt']);
    %             %         fid2 = fopen([outputPath '/' tmp2(length(tmp2)).name]);
    %             %         ladders = textscan(fid2, '%d %d %d', 'Headerlines',1);
    %             %         fclose(fid2);
    %             %         Ladder1{runNum}(1,1) = ladders{1};
    %             %         Ladder2{runNum}(1,1) = ladders{2};
    %             %         %         runInd = ladders{3}+1;
    %         end
    
    
    %   Loop through all trials in a run
    %---------------------------
    runStartTime = GetSecs - anchor;
    
%         for trialNum = 1:6; % shorter version for debugging
    for trialNum = 1:length(shuff_trialType{runNum})   % To cover all the items in one run.
        
        Screen('PutImage',w,Images{trialNum});
        Screen('Flip',w,anchor+onsets(trialNum)+runStartTime); % display images according to Onset times
        image_start_time = GetSecs;
        actual_onset_time{runNum}(trialNum,1) = image_start_time - anchor ;
        
        if use_eyetracker
            %   Eyelink MSG
            % ---------------------------
            % messages to save on each trial ( trial number, onset and RT)
            Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' stim: ',shuff_names{runNum}{trialNum},' start_time: ',num2str(image_start_time)]); % mark start time in file
        end
        
        noresp = 1;
        notone = 1;
        
        KbQueueFlush;
        KbQueueStart;
        
        %---------------------------------------------------
        %% 'EVALUATE RESPONSE & ADJUST LADDER ACCORDINGLY'
        %---------------------------------------------------
        while (GetSecs-image_start_time < image_duration)
            
            %High-Valued BEEP items
            %---------------------------
            if  shuff_trialType{runNum}(trialNum) == 11 && (GetSecs - image_start_time >= Ladder1{runNum}(length(Ladder1{runNum}),1)/1000) && notone % shuff_trialType contains the information if a certain image is a GO/NOGO trial
                % Beep!
                clc;
                disp('BEEP')
                if use_PTB_audio==1
%                     PsychPortAudio('FillBuffer', pahandle, wave);
                    PsychPortAudio('Start', pahandle, 1, 0, 0);
                elseif use_PTB_audio==0
                    play(Audio);
                end
                notone = 0;
                Audio_time{runNum}(trialNum,1) = GetSecs-image_start_time;
                
                if use_eyetracker
                    %   Eyelink MSG
                    % ---------------------------
                    Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' cue_start: ',num2str(GetSecs)]); % mark start time in file
                end
                
                %   look for response
                [pressed, firstPress, ~, ~, ~] = KbQueueCheck;
                if pressed && noresp
                    firstKeyPressed = find(firstPress==min(firstPress(firstPress>0)));
                    
                    
                    %%%
                    if length(firstKeyPressed)>=2
                        firstKeyPressed=firstKeyPressed(1);
                    end
                    %%%
                    
                    respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                    %                     findfirstPress = find(firstPress);
                    %                     respTime{runNum}(trialNum,1) = firstPress(findfirstPress(1))-image_start_time;
                    tmp = KbName(firstKeyPressed);
                    if ischar(tmp) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                        tmp = char(tmp);
                    end
                    keyPressed{runNum}(trialNum,1) = tmp(1);
                    
                    
                    % different response types in scanner or in testing room
                    if test_comp == 1
                        if keyPressed{runNum}(trialNum,1) == blue || keyPressed{runNum}(trialNum,1) == yellow
                            noresp = 0;
                            if use_eyetracker
                                %   Eyelink MSG
                                % ---------------------------
                                Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ',num2str(GetSecs)]); % mark start time in file
                            end
                            
                            if respTime{runNum}(trialNum,1) < Ladder1{runNum}(length(Ladder1{runNum}),1)/1000
                                respInTime{runNum}(trialNum,1) = 11; %was a GO trial with HV item but responded before SS
                            else
                                respInTime{runNum}(trialNum,1)= 110; %was a Go trial with HV item but responded after SS within 1000 msec
                            end
                        end
                    else
                        
                        if keyPressed{runNum}(trialNum,1) == BUTTON %| keyPressed{runnum}(trialnum,1)==RIGHT
                            noresp = 0;
                            if use_eyetracker
                                %   Eyelink MSG
                                % ---------------------------
                                Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ',num2str(GetSecs)]); % mark start time in file
                            end
                            if respTime{runNum}(trialNum,1) < Ladder1{runNum}(length(Ladder1{runNum}),1)/1000
                                respInTime{runNum}(trialNum,1) = 11; %was a GO trial with HV item but responded before SS
                            else
                                respInTime{runNum}(trialNum,1) = 110; %was a Go trial with HV item and responded after SS within 1000 msec - good trial
                            end
                        end
                    end % if test_comp == 1
                    
                end
                
                %Low-Valued BEEP items
                %---------------------------
            elseif  shuff_trialType{runNum}(trialNum) == 22 && (GetSecs - image_start_time >= Ladder2{runNum}(length(Ladder2{runNum}),1)/1000) && notone %shuff_trialType contains the information if a certain image is a GO/NOGO trial
                clc;
                disp('BEEP')
                % Beep!
                if use_PTB_audio==1
%                     PsychPortAudio('FillBuffer', pahandle, wave);
                    PsychPortAudio('Start', pahandle, 1, 0, 0);
                elseif use_PTB_audio==0
                    play(Audio);
                end
                notone = 0;
                Audio_time{runNum}(trialNum,1) = GetSecs-image_start_time;
                
                if use_eyetracker
                    %   Eyelink MSG
                    % ---------------------------
                    Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' cue_start: ',num2str(GetSecs)]); % mark start time in file
                end
                
                %   look for response
                [pressed, firstPress, ~, ~, ~] = KbQueueCheck;
                if pressed && noresp
                    firstKeyPressed = find(firstPress==min(firstPress(firstPress>0)));
                    
                    
                    %%%
                    if length(firstKeyPressed)>=2
                        firstKeyPressed=firstKeyPressed(1);
                    end
                    %%%
                    
                    respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                    %                     findfirstPress = find(firstPress);
                    %                     respTime{runNum}(trialNum,1) = firstPress(findfirstPress(1))-image_start_time;
                    tmp = KbName(firstKeyPressed);
                    if ischar(tmp) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                        tmp = char(tmp);
                    end
                    keyPressed{runNum}(trialNum,1) = tmp(1);
                    respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                    
                    %   different response types in scanner or in testing room
                    if test_comp == 1
                        if keyPressed{runNum}(trialNum,1) == blue || keyPressed{runNum}(trialNum,1) == yellow
                            noresp = 0;
                            if respTime{runNum}(trialNum,1) < Ladder2{runNum}(length(Ladder2{runNum}),1)/1000
                                respInTime{runNum}(trialNum,1) = 22; %was a GO trial with LV item but responded before SS
                            else
                                respInTime{runNum}(trialNum,1) = 220; %was a Go trial with LV item but responded after SS within 1000 msec
                            end
                        end
                    else
                        if keyPressed{runNum}(trialNum,1) == BUTTON %| keyPressed{runnum}(trialnum,1)==RIGHT
                            noresp = 0;
                            if respTime{runNum}(trialNum,1) < Ladder2{runNum}(length(Ladder2{runNum}),1)/1000
                                respInTime{runNum}(trialNum,1) = 22;  %was a GO trial with LV item but responded before SS
                            else
                                respInTime{runNum}(trialNum,1) = 220; %was a Go trial with LV item and responded after SS within 1000 msec - good trial
                            end
                        end
                    end % if test_comp == 1
                    
                end % end if pressed && noresp
                
                %No-BEEP
                %---------------------------
            elseif   mod(shuff_trialType{runNum}(trialNum),11) ~= 0 && noresp % these will now be the NOGO trials
                
                %   look for response
                [pressed, firstPress, ~, ~, ~] = KbQueueCheck;
                if pressed && noresp
                    firstKeyPressed = find(firstPress==min(firstPress(firstPress>0)));
                    
                    %%%
                    if length(firstKeyPressed)>=2
                        firstKeyPressed=firstKeyPressed(1);
                    end
                    %%%
                    
                    respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                    %                     findfirstPress = find(firstPress);
                    %                     respTime{runNum}(trialNum,1) = firstPress(findfirstPress(1))-image_start_time;
                    tmp = KbName(firstKeyPressed);
                    if ischar(tmp) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                        tmp = char(tmp);
                    end
                    keyPressed{runNum}(trialNum,1) = tmp(1);
                    
                    % different response types in scanner or in testing room
                    if test_comp == 1
                        if keyPressed{runNum}(trialNum,1) == blue || keyPressed{runNum}(trialNum,1) == yellow
                            noresp = 0;
                            if use_eyetracker
                                %   Eyelink MSG
                                % ---------------------------
                                Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ',num2str(GetSecs)]); % mark start time in file
                            end
                            
                            if shuff_trialType{runNum}(trialNum) == 12
                                respInTime{runNum}(trialNum,1) = 12; % a stop trial but responded within 1000 msec HV item - not good but don't do anything
                            else
                                respInTime{runNum}(trialNum,1) = 24; % a stop trial but responded within 1000 msec LV item - not good but don't do anything
                            end
                        end
                    else
                        if keyPressed{runNum}(trialNum,1) == BUTTON %| keyPressed{runnum}(trialnum,1)==RIGHT
                            noresp = 0;
                            if use_eyetracker
                                %   Eyelink MSG
                                % ---------------------------
                                Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ',num2str(GetSecs)]); % mark start time in file
                            end
                            if shuff_trialType{runNum}(trialNum) == 12
                                respInTime{runNum}(trialNum,1) = 12; %% a stop trial but responded within 1000 msec HV item - not good but don't do anything
                            else
                                respInTime{runNum}(trialNum,1) = 24; %% a stop trial but responded within 1000 msec LV item - not good but don't do anything
                            end
                        end
                    end % end if test+comp == 1
                    
                end % end if pressed && noresp
            end %evaluate trial_type
            
        end %%% End big while waiting for response within 1000 msec
        
        
        %   Close the Audio port and open a new one
        %------------------------------------------
        if use_PTB_audio==1
            %                 PsychPortAudio('Stop', pahandle);
%             PsychPortAudio('Close', pahandle);
%             pahandle = PsychPortAudio('Open', deviceID, [], reqlatencyclass, freq, nrchannels);
%             PsychPortAudio('RunMode', pahandle, 1);
            PsychPortAudio('FillBuffer', pahandle, wave);
        end
        
        %   Show fixation
        %---------------------------
        CenterText(w,'+', white,0,0);
        Screen('TextSize',w, 60);
        Screen(w,'Flip', image_start_time+1);
        fix_time{runNum}(trialNum,1) = GetSecs ;
        fixcrosstime{runNum} = GetSecs;
        if use_eyetracker
            %   Eyelink MSG
            % ---------------------------
            Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Fixation_ITI_start: ',num2str(GetSecs)]); % mark start time in file
        end
        
        if noresp == 1
            %---------------------------
            % these are additional 500msec to monitor responses
            
            while (GetSecs-fix_time{runNum}(trialNum,1) < 0.5)
                
                %   look for response
                [pressed, firstPress, ~, ~, ~] = KbQueueCheck;
                if pressed && noresp
                    firstKeyPressed = find(firstPress==min(firstPress(firstPress>0)));
                    
                    %%%
                    if length(firstKeyPressed)>=2
                        firstKeyPressed=firstKeyPressed(1);
                    end
                    %%%
                    
                    respTime{runNum}(trialNum,1) = firstPress(firstKeyPressed)-image_start_time;
                    %                     findfirstPress = find(firstPress);
                    %                     respTime{runNum}(trialNum,1) = firstPress(findfirstPress(1))-image_start_time;
                    tmp = KbName(firstKeyPressed);
                    if ischar(tmp) == 0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed{runnum} to be a char, so this converts it and takes the first key pressed
                        tmp = char(tmp);
                    end
                    keyPressed{runNum}(trialNum,1) = tmp(1);
                    
                    if test_comp == 1
                        if keyPressed{runNum}(trialNum,1) == blue || keyPressed{runNum}(trialNum,1) == yellow
                            noresp = 0;
                            if use_eyetracker
                                %   Eyelink MSG
                                % ---------------------------
                                Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ',num2str(GetSecs)]); % mark start time in file
                            end
                            switch shuff_trialType{runNum}(trialNum)
                                case 11
                                    if respTime{runNum}(trialNum,1) >= 1
                                        respInTime{runNum}(trialNum,1) = 1100; % a Go trial and  responded after 1000msec  HV item - make it easier decrease SSD
                                    elseif respTime{runNum}(trialNum,1) < 1
                                        respInTime{runNum}(trialNum,1) = 110;
                                    end
                                case 22
                                    if respTime{runNum}(trialNum,1) >= 1
                                        respInTime{runNum}(trialNum,1) = 2200; % a Go trial and  responded after 1000msec  HV item - make it easier decrease SSD
                                    elseif respTime{runNum}(trialNum,1) < 1
                                        respInTime{runNum}(trialNum,1) = 220;
                                    end
                                case 12
                                    respInTime{runNum}(trialNum,1) = 12; % a stop trial and responded after 1000 msec  HV item - don't touch
                                case 24
                                    respInTime{runNum}(trialNum,1) = 24; % % a stop trial and  responded after 1000 msec HV item - don't touch
                            end
                        end
                        
                    else
                        
                        if keyPressed{runNum}(trialNum,1) == BUTTON % | keyPressed{runnum}(trialnum,1)==RIGHT
                            noresp = 0;
                            if use_eyetracker
                                %   Eyelink MSG
                                % ---------------------------
                                Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' Press_time: ',num2str(GetSecs)]); % mark start time in file
                            end
                            switch shuff_trialType{runNum}(trialNum)
                                case 11
                                    if respTime{runNum}(trialNum,1) >= 1
                                        respInTime{runNum}(trialNum,1) = 1100;% a Go trial and responded after 1000msec  HV item  - make it easier decrease SSD
                                    elseif respTime{runNum}(trialNum,1) < 1
                                        respInTime{runNum}(trialNum,1) = 110;% a Go trial and responded before 1000msec  HV item  -  make it harder increase SSD/3
                                    end
                                case 22
                                    if respTime{runNum}(trialNum,1) > 1
                                        respInTime{runNum}(trialNum,1) = 2200;% a Go trial and responded after 1000msec  LV item - - make it easier decrease SSD
                                    elseif respTime{runNum}(trialNum,1) < 1
                                        respInTime{runNum}(trialNum,1) = 220;% a Go trial and responded before 1000msec  LV item - - make it harder increase SSD/3
                                    end
                                case 12
                                    respInTime{runNum}(trialNum,1) = 12;% a NOGO trial and didnt respond on time HV item - don't touch
                                case 24
                                    respInTime{runNum}(trialNum,1) = 24;% a NOGO trial and didnt respond on time LV item - don't touch
                                    
                            end
                        end
                    end % end if test_comp == 1
                end % end if pressed && noresp
            end % End while of additional 500 msec
        else % the subject has already responded during the first 1000 ms
            WaitSecs(0.5);
        end  % end if noresp
        
        %%	This is where its all decided !
        %---------------------------
        if noresp
            switch shuff_trialType{runNum}(trialNum)
                case 11
                    respInTime{runNum}(trialNum,1) = 1; %unsuccessful Go trial HV - didn't press a button at all - trial too hard - need to decrease ladder
                case 22
                    respInTime{runNum}(trialNum,1) = 2; % unsuccessful Go trial LV - didn't press a button at all - trial too hard - need to decrease ladder
                case 12
                    respInTime{runNum}(trialNum,1) = 120; % ok NOGO trial didn't respond after 1500 msec in NOGO trial HV
                case 24
                    respInTime{runNum}(trialNum,1) = 240; % ok NOGO trial didn't respond after 1500 msec in NOGO trial LV
            end
        end
        
        
        switch respInTime{runNum}(trialNum,1)
            case 1 % didn't respond even after 1500 msec on HV GO trial - make it easier decrease SSD by step
                if (Ladder1{runNum}(length(Ladder1{runNum}),1)<0.001)
                    Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1);
                else
                    Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1)-Step;
                end;
                
            case 2 % didn't respond even after 1500 msec on LV GO trial - make it easier decrease SSD by step
                if (Ladder2{runNum}(length(Ladder2{runNum}),1)<0.001)
                    Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1);
                else
                    Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1)-Step;
                end;
                
                
            case 1100 %  responded after 1500 msec on HV GO trial - make it easier decrease SSD by step
                if (Ladder1{runNum}(length(Ladder1{runNum}),1)<0.001)
                    Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1);
                else
                    Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1)-Step;
                end;
                
            case 2200 %  responded after 1500 msec on LV GO trial - make it easier decrease SSD by step
                if (Ladder2{runNum}(length(Ladder2{runNum}),1)<0.001)
                    Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1);
                else
                    Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1)-Step;
                end;
                
                
                
            case 11
                if (Ladder1{runNum}(length(Ladder1{runNum}),1) > 910); %was a GO trial with HV item but responded before SS make it harder - increase SSD by Step/3
                    Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1);
                else
                    Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1)+Step/3;
                end;
                
            case 22
                if (Ladder2{runNum}(length(Ladder2{runNum}),1) > 910); %was a GO trial with LV item but responded before SS make it harder - - increase SSD by Step/3
                    Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1);
                else
                    Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1)+Step/3;
                end;
                
            case 110 % pressed after Go signal but below 1000 - - increase SSD by Step/3 - these are the good trials!
                if (Ladder1{runNum}(length(Ladder1{runNum}),1) > 910);
                    Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1);
                else
                    Ladder1{runNum}(length(Ladder1{runNum})+1,1) = Ladder1{runNum}(length(Ladder1{runNum}),1)+Step/3;
                end;
                
            case 220 % pressed after Go signal but below 1000 - - increase SSD by Step/3 - these are the good trials!
                if (Ladder2{runNum}(length(Ladder2{runNum}),1) > 910);
                    Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1);
                else
                    Ladder2{runNum}(length(Ladder2{runNum})+1,1) = Ladder2{runNum}(length(Ladder2{runNum}),1)+Step/3;
                end;
                
        end % end switch respInTime{runNum}(trialNum,1)
        
        %   'Save data'
        %---------------------------
        
        fprintf(fid1,'%s\t %d\t %d\t %s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %.2f\t %.2f\t %.2f\t %d\t %.2f\t \n', subjectID, order, runNum, shuff_names{runNum}{trialNum}, actual_onset_time{runNum}(trialNum,1), shuff_trialType{runNum}(trialNum), respTime{runNum}(trialNum,1)*1000, respInTime{runNum}(trialNum,1), Audio_time{runNum}(trialNum,1)*1000, keyPressed{runNum}(trialNum,1),   fix_time{runNum}(trialNum,1)-anchor, Ladder1{runNum}(length(Ladder1{runNum})), Ladder2{runNum}(length(Ladder2{runNum})), shuff_bidIndex{runNum}(trialNum,1), shuff_itemnameIndex{runNum}(trialNum,1),shuff_bidValues{runNum}(trialNum,1));
        
    end; %	End the big trialNum loop showing all the images in one run.
    
    KbQueueFlush;
    
    Ladder1end{runNum} = Ladder1{runNum}(length(Ladder1{runNum}));
    Ladder2end{runNum} = Ladder2{runNum}(length(Ladder2{runNum}));
    correct{runNum}(1) = 0;
    % Correct trials are when the subject pressed the button on a go trial,
    % either before (11,22) or after (110,220)the beep (but before the
    % image disappeared)
    correct{runNum}(1) = length(find(respInTime{runNum} == 11 | respInTime{runNum} == 110 | respInTime{runNum} == 22 | respInTime{runNum} == 220 ));
    numGoTrials(runNum) = length(find(trialType{runNum} == 11 | trialType{runNum} == 22));
    mean_RT{runNum} = mean(respTime{runNum}(respInTime{runNum} == 110 | respInTime{runNum} == 220));
    

end % End the run loop to go over all the runs

    % afterrun fixation
    % ---------------------------
    if use_eyetracker
        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message', ['run: ',num2str(runNum),' trial: ' num2str(trialNum) ' End_trial_fixation_time: ',num2str(GetSecs)]); % mark start time in file
    end
    
    postexperiment = GetSecs;
    
    while GetSecs < postexperiment+afterrunfixation;
        CenterText(w,'+', white,0,0);
        Screen('TextSize',w, 60);
        Screen(w,'Flip');    
    end
    runInd=runInd+1;


%   write Ladders info to txt file
% ------------------------------
%     fid2 = fopen([outputPath '\' subjectID sprintf('_ladders_run_%d.txt', runNum)], 'w');
%     fprintf(fid2,'Ladder1\t Ladder2\t runnum\t \n'); %write the header line
%     fprintf(fid2, '%d\t %d\t %d\t \n', Ladder1{runNum}(length(Ladder1{runNum})), Ladder2{runNum}(length(Ladder2{runNum})),runNum);
%     fprintf(fid2, '\n');
%     fclose(fid2);



%---------------------------------------------------------------
%%   save data to a .mat file & close out
%---------------------------------------------------------------
outfile = strcat(outputPath, '/', subjectID,'_training_run', sprintf('%02d',runNum-num_runs_per_block+1),'_to_run', sprintf('%02d',runNum),'_', timestamp,'.mat');
% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;
run_info.script_version = script_version;
run_info.revision_date = revision_date;
run_info.script_name = mfilename;
clear Images Instructions_image;

save(outfile);

if use_PTB_audio==1
    % % Close the audio device:
    PsychPortAudio('Close', pahandle);
end

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
        movefile(edfFile,['./Output/', subjectID,'_Training_run_',num2str(runNum-2),'_to_run_',num2str(runNum),'_',timestamp,'.edf']);
    end;
end

%   outgoing msg & closing
% ------------------------------
if runNum ~= total_number_of_runs % if this is not the last run
    goodTrials = correct{runNum-1} + correct{runNum};
    goTrials = numGoTrials(runNum-1) + numGoTrials(runNum);
    Screen('TextSize', w, 40); %Set textsize
        CenterText(w,sprintf('Another run will begin soon'), white, 0,-300);
    Screen('Flip',w);
else % if this is the last run
    CenterText(w,'Great Job. Thank you!',Green, 0,-270);
    CenterText(w,'Now we will continue to the next part', white, 0, -180);
    Screen('Flip',w);
end

WaitSecs(4);

KbQueueFlush;
Screen('CloseAll');
ShowCursor;



if runInd<total_number_of_runs
    fprintf(['\nyour next block is: ' num2str(block+1),'\n\n']);
    block=block+1;
else
    disp('continue to next part');
end

clear all

