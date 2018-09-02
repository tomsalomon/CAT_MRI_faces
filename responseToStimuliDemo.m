% script_oneSeveralDemonstration
clear all;
% Screen('Preference', 'SkipSyncTests', 1);

% input checkers
subjectID = input('Subject code: ','s');
[subjectID_num,okID]=str2num(subjectID(end-2:end));
while okID==0
    disp('ERROR: Subject code must contain 3 characters numeric ending, e.g "BMI_bf_101". Please try again.');
    subjectID = input('Subject code:','s');
    [subjectID_num,okID]=str2num(subjectID(end-2:end));
end

okEyetracker = [1 0];
ask_if_want_eyetracker = input('Do you want eyetracking (1 - yes, 0 - no): ');
    while isempty(ask_if_want_eyetracker) || sum(okEyetracker == ask_if_want_eyetracker) ~=1
        disp('ERROR: input must be 1 or 0. Please try again.');
        ask_if_want_eyetracker = input('Do you want eyetracking (1 - yes, 0 - no): ');
    end
use_eyetracker=ask_if_want_eyetracker; % set to 1/0 to turn on/off eyetracker functions

%---------------------------------------------------------------
% 'GLOBAL VARIABLES'
%---------------------------------------------------------------
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp = [date,'_',hr,'h',min,'m'];

% Set main path
mainPath = pwd;

% load demo names
demoNames=dir([mainPath,'/Stim/demo/*.jpg']);

% load demo images
demo_images = cell(length(demoNames),1);
for ind = 1:length(demoNames)
    demo_images{ind} = imread(sprintf('Stim/demo/%s',demoNames(ind).name));
end

% Load Hebrew instructions image files
Instructions = dir([mainPath '/Instructions/fmri_response_to_stimuli_demo.JPG' ]);
Instructions_image = imread([mainPath '/Instructions/' Instructions(1).name]);

% INITIALIZE Screen variables's
%---------------------------------------------------------------
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = max(Screen('Screens'));

pixelSize = 32;
% [w] = Screen('OpenWindow',screennum,[],[0 0 1280 720],pixelSize); % debugging screensize
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

% Set Colors
% - - - - - - - - - - - - - - - - -
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
Green = [0 255 0];

% set up Screen positions for stimuli
% - - - - - - - - - - - - - - - - -
[wWidth, wHeight] = Screen('WindowSize', w);
xcenter = wWidth/2;
ycenter = wHeight/2;

Screen('FillRect', w, black);  % NB: only need to do this once!
Screen('Flip', w);

% setting the text
% - - - - - - - - - - - - - - - - -
theFont = 'Arial';
Screen('TextFont',w,theFont);
Screen('TextSize',w, 60);


% stimuli location and size
% - - - - - - - - - - - - - - - - -
sizeFactor = 1;
stimW = size(demo_images{1},2)*sizeFactor;
stimH = size(demo_images{1},1)*sizeFactor;
rect = [xcenter-stimW/2 ycenter-stimH/2 xcenter+stimW/2 ycenter+stimH/2];

Screen('FillRect', w, black);  % NB: only need to do this once!
Screen('Flip', w);

HideCursor;

%-----------------------------------------------------------------
% Initializing eye tracking system %
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
    edfFile='R2S_demo.edf';
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

% show instructions
Screen('PutImage',w,Instructions_image);
Screen(w,'Flip');
noResponse=1;
while noResponse,
    [keyIsDown,~,~] = KbCheck; %(experimenter_device);
    if keyIsDown && noResponse,
        noResponse=0;
    end;
end;
WaitSecs(0.001);

% read the vector of oneSeveral of demo items, in whitch there is 1 for
% 'one' and 2 for 'several'


CenterText(w,'+', white,0,0);
Screen('TextSize',w, 60);
Screen(w,'Flip');
WaitSecs(2);

itemsCode=cell(length(demoNames)-1,1);
shuffle_list=Shuffle(1:length(demoNames));

if use_eyetracker
    % start recording eye position
    %---------------------------
    Eyelink('StartRecording');
    WaitSecs(.05);
    
    %   Eyelink MSG
    % ---------------------------
    % messages to save on each trial ( trial number, onset and RT)
    Eyelink('Message', 'SYNCTIME at run start'); % mark start time in file 
end

% Show each item with the answer whether it is male or female
for itemInd = 1:length(demoNames)-1 % show all stim minus one, so the number of male and female will not be equal
    
    itemsCode{itemInd}=demoNames(shuffle_list(itemInd)).name(1:end-4); % get the code of the image, which indicate if its a male or a female
    
    Screen('PutImage',w,demo_images{shuffle_list(itemInd)},rect);
    Screen(w,'Flip');

    if use_eyetracker
        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message',['trial ',num2str(itemInd),'time:',num2str(GetSecs)]);
    end
        
    WaitSecs(2);
    
    CenterText(w,'+', white,0,0);
    Screen('TextSize',w, 60);
    Screen(w,'Flip');
    if use_eyetracker
        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message',['ITI fixation time:',num2str(GetSecs)]);
    end
    
    WaitSecs(2);
end % end for itemInd = 1:length(demoNames)

    if use_eyetracker
        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message',['end of part time:',num2str(GetSecs)]);
    end
    
itemsCode_num=str2num(cell2mat(itemsCode));
num_of_males=sum(itemsCode_num<4000);

CenterText(w,'How many males did you see?', white,0,0);
Screen(w,'Flip');
WaitSecs(4);

CenterText(w,sprintf('There was a total of %d males',num_of_males), white,0,-100);
CenterText(w,sprintf('and a total of %d females',length(demoNames)-1-num_of_males), white,0,0);
Screen(w,'Flip');
WaitSecs(5);

Screen('CloseAll');
ShowCursor;

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
        movefile(edfFile,['./Output/', subjectID,'_DemoResponseToStimuli_eyetracking_', timestamp,'.edf']);
    end;
end