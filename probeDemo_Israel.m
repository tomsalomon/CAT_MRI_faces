
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Tom Salomon, September 2015 =====================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs the demo of the probe session of the boost (cue-approach) task.


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'Misc/demo_items.txt'

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   ''probe_demo_' timestamp '.txt''
% 
%   Also saves data to 'Demo' sheet of xls file created in the general
%   'run_boost_Israel_new' function: ''probe_results_' probeType '_' timestamp'

tic


%---------------------------------------------------------------
%% 'GLOBAL VARIABLES'
%---------------------------------------------------------------
clear all

rng shuffle
Screen('Preference', 'SkipSyncTests', 1);
% =========================================================================
% Get input args and check if input is ok
% =========================================================================

oksessionNum = [1 2 3];
okComputer = [0 1 2 3 4 5];

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

sessionNum=1; % 1 if this is the first time the subject is tested

% =========================================================================
% set the computer and path
% =========================================================================
test_comp=1; % 1 for MRI, 0 for test computer

% Set main path
mainPath=pwd;
outputPath = [mainPath '/Output'];

%   'timestamp'
% - - - - - - - - - - - - - - - - -
c = clock;
hr = sprintf('%02d', c(4));
minutes = sprintf('%02d', c(5));
timestamp=[date,'_',hr,'h',minutes,'m'];

% essential for randomization
rng('shuffle');

%   'set phase times'
% - - - - - - - - - - - - - - - - -
maxtime = 1.5;      % 1.5 second limit on each selection
baseline_fixation_dur = 2; % Need to modify based on if first few volumes are saved or not
% afterrunfixation = 6;

tic

%---------------------------------------------------------------
%% 'Load image arrays'
%---------------------------------------------------------------
% load image arrays
% - - - - - - - - - - - - - - -
% Read all image files in the 'stim' folder. make sure the ending is suitable 
% to your stimuli, and the folder contains only the experiment's 60 images.
stimuli=dir([mainPath '/stim/demo/*.jpg' ]);
stimname=struct2cell(rmfield(stimuli,{'date','bytes','isdir','datenum'}));
Images=cell(length(stimname),1);
for i=1:length(stimname)
    Images{i}=imread([mainPath '/stim/demo/',sprintf(stimname{i})]);
end

%  Load Hebrew instructions image files 
% -----------------------------------------------
%% Load Instructions
% -----------------------------------------------
% Load Hebrew instructions image files
Instructions = dir([mainPath '/Instructions/probe_demo.JPG' ]);
Instructions_fmri = dir([mainPath '/Instructions/fmri_probe_demo.JPG' ]);
Instructions_image = imread([mainPath '/Instructions/' Instructions(1).name]);
Instructions_image_fmri = imread([mainPath '/Instructions/' Instructions_fmri(1).name]);

%   'load onsets'
% - - - - - - - - - - - - - - -
r = Shuffle(1:2); %re-shuffled done every run
onsetlist = load(['Onset_files/probe_onset_' num2str(r(1)) '.mat']);
onsetlist = onsetlist.onsetlist;

%---------------------------------------------------------------
%% 'INITIALIZE Screen variables's
%---------------------------------------------------------------
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = max(Screen('Screens'));

pixelSize = 32;
% [w] = Screen('OpenWindow',screennum,[],[0 0 640 480],pixelSize/4); % debugging screensize
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

% Here Be Colors
% - - - - - - - - - - - - - - - - -
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
green = [0 255 0];



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
Screen('TextSize',w, 28);


% Define image scale - Change according to your stimuli
% - - - - - - - - - - - - - - -
stackH= size(Images{1},1);
stackW= size(Images{1},2);

xDist = 300; % distance from center in the x axis. can be changed to adjust to smaller screens
leftRect = [xcenter-stackW-xDist ycenter-stackH/2 xcenter-xDist ycenter+stackH/2];
rightRect = [xcenter+xDist ycenter-stackH/2 xcenter+stackW+xDist ycenter+stackH/2];

penWidth = 10;

HideCursor;

%---------------------------------------------------------------
%% 'Assign response keys'
%---------------------------------------------------------------

KbName('UnifyKeyNames');

switch test_comp
    case {0,2,3}
        leftstack = 'u';
        rightstack = 'i';
        badresp = 'x';
    case 1
        leftstack = 'b';
        rightstack = 'y';
        badresp = 'x';
end % end switch test_comp

%---------------------------------------------------------------
%%   'PRE-TRIAL DATA ORGANIZATION'
%---------------------------------------------------------------

% Determine stimuli to use
% - - - - - - - - - - - - - - - - -


HH_HS = [1 2 3 4];
HH_HG = [5 6 7 8];


leftGo = cell(1,5);
stimnum1 = cell(1,5);
stimnum2 = cell(1,5);
leftname = cell(1,5);
rightname = cell(1,5);
pairtype = cell(1,5);

for block = 1:1
    pairtype{block} = [1 1 1 1];
    leftGo{block} = Shuffle([1 1 0 0 ]);
end;

HH=1;
% LL=1;
% HL_S=1;
% HL_G=1;


for i=1:4 % trial num within block
    stimnum1{block}(i)=HH_HS(HH);
    stimnum2{block}(i)=HH_HG(HH);
    HH=HH+1;
    if leftGo{block}(i)==1
        leftname{block}(i)=stimname(stimnum1{block}(i));
        rightname{block}(i)=stimname(stimnum2{block}(i));
    else
        leftname{block}(i)=stimname(stimnum1{block}(i));
        rightname{block}(i)=stimname(stimnum2{block}(i));
    end
    
end % end for i=1:4

%ListenChar(2); %suppresses terminal ouput
KbQueueCreate;
%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1=fopen([outputPath '/' subjectID sprintf('_probe_demo_') timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\tscanner\torder\truntrial\tonsettime\tImageLeft\tImageRight\tTypeLeft\tTypeRight\tIsleftGo\tResponse\tPairType\tOutcome\tRT \n'); %write the header line

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, 40);

%%% While they are waiting for the trigger
if test_comp == 1
    %     if sessionNum == 1;
    %         CenterText(w,'PART 5:', white,0,-325);
    %     else
    %         CenterText(w,'PART 2:', white,0,-325);
    %     end
    
    Screen('PutImage',w,Instructions_image_fmri);
    Screen(w,'Flip');
    
    % wait for the subject to press the button
    noresp = 1;
    while noresp,
        [keyIsDown,~,~] = KbCheck; %(experimenter_device);
        if keyIsDown && noresp,
            noresp = 0;
        end;
    end;
    
else

    Screen('PutImage',w,Instructions_image);
    Screen('Flip',w);
    
    noresp = 1;
    while noresp,
        [keyIsDown] = KbCheck(-1); % deviceNumber=keyboard
        if keyIsDown && noresp,
            noresp = 0;
        end;
    end;
    
    WaitSecs(0.001);
    %DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected
    
end % end if test_comp == 1


% Screen('Flip',w);



prebaseline = GetSecs;
%KbQueueFlush;
KbQueueCreate;


%-----------------------------------------------------------------

while GetSecs < prebaseline + baseline_fixation_dur
    CenterText(w,'+', white,0,0);
    Screen('TextSize',w, 60);
    Screen(w,'Flip');
    
end
%-----------------------------------------------------------------
% postbaseline = GetSecs;
% baseline_fixation = postbaseline - prebaseline;

%---------------------------------------------------------------
%% 'Run Trials'
%---------------------------------------------------------------
runtrial = 1;
runStart = GetSecs;



for block=1:1
    for trial=1:4
   
        out=999;
        %-----------------------------------------------------------------
        % display images
        if leftGo{block}(trial)==1
            Screen('PutImage',w,Images{stimnum1{block}(trial)}, leftRect);
            Screen('PutImage',w,Images{stimnum2{block}(trial)}, rightRect);
        else
            Screen('PutImage',w,Images{stimnum2{block}(trial)}, leftRect);
            Screen('PutImage',w,Images{stimnum1{block}(trial)}, rightRect);
        end
        CenterText(w,'+', white,0,0);
        Screen(w,'Flip', runStart+onsetlist(runtrial));
        StimOnset = GetSecs;
        
    KbQueueFlush;
    KbQueueStart;
    
    %-----------------------------------------------------------------
    % get response
    %-----------------------------------------------------------------
        
        
        noresp = 1;
        goodresp = 0;
        while noresp
            % check for response
            [keyIsDown, firstPress] = KbQueueCheck;
            
            
            if keyIsDown && noresp
                keyPressed = KbName(firstPress);
                if ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                    keyPressed = char(keyPressed);
                    keyPressed = keyPressed(1);
                end
                switch keyPressed
                    case leftstack
                        respTime = firstPress(KbName(leftstack))-StimOnset;
                        noresp = 0;
                        goodresp = 1;
                    case rightstack
                        respTime = firstPress(KbName(rightstack))-StimOnset;
                        noresp = 0;
                        goodresp = 1;
                end
            end % end if keyIsDown && noresp
            
            
            % check for reaching time limit
            if noresp && GetSecs-runStart >= onsetlist(runtrial)+maxtime
                noresp = 0;
                keyPressed = badresp;
                respTime = maxtime;
            end
        end % end while noresp
        
        
        %-----------------------------------------------------------------
        
        
        % determine what bid to highlight
        
        switch keyPressed
            case leftstack
                if leftGo{block}(trial)==0
                    out=0;
                else
                    out=1;
                end
            case rightstack
                if leftGo{block}(trial)==1
                    out=0;
                else
                    out=1;
                end
        end % end switch keyPressed
        
        if goodresp==1
            if leftGo{block}(trial)==1
                Screen('PutImage',w,Images{stimnum1{block}(trial)}, leftRect);
                Screen('PutImage',w,Images{stimnum2{block}(trial)}, rightRect);
            else
                Screen('PutImage',w,Images{stimnum2{block}(trial)}, leftRect);
                Screen('PutImage',w,Images{stimnum1{block}(trial)}, rightRect);
            end
            
        switch keyPressed
            case leftstack
            Screen('FrameRect', w, green, leftRect, penWidth);
            case rightstack
            Screen('FrameRect', w, green, rightRect, penWidth);
        end
            
            
            CenterText(w,'+', white,0,0);
            Screen(w,'Flip',runStart+onsetlist(trial)+respTime);
            
        else % if did not respond: show text 'You must respond faster!'
%         Screen('DrawText', w, 'You must respond faster!', xcenter-450, ycenter, white);
        CenterText(w,sprintf('You must respond faster!') ,white,0,0);
        Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime);
        end
        
        
        %-----------------------------------------------------------------
        % show fixation ITI
        CenterText(w,'+', white,0,0);
        Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime+.5);
        
        if goodresp ~= 1
            respTime=999;
        end
        
        %-----------------------------------------------------------------
        % save data to .txt and .xls files
        fprintf(fid1,'%s\t%d\t%d\t%d\t%d\t%s\t%s\t%d\t%d\t%d\t%s\t%d\t%d\t%.2f \n', subjectID, test_comp, order, runtrial, onsetlist(runtrial), char(leftname{block}(trial)), char(rightname{block}(trial)), stimnum1{block}(trial), stimnum2{block}(trial), leftGo{block}(trial), keyPressed, pairtype{block}(trial), out, respTime*1000);
%         dataToSave = {runtrial, onsetlist(runtrial), char(leftname{block}(trial)), char(rightname{block}(trial)), stimnum1{block}(trial), stimnum2{block}(trial), leftGo{block}(trial), keyPressed, pairtype{block}(trial), out, respTime*1000};
%         dataRange = ['A' num2str(6+runtrial)];
%         xlswrite(xlsfilename,dataToSave,'Demo',dataRange);
%         timestamp_cell={timestamp};
%         xlswrite(xlsfilename,timestamp_cell,'Demo','B3');
        runtrial = runtrial+1;
        KbQueueFlush;
    end
end % end for block = 1:1

WaitSecs(2);
Screen('FillRect', w, black);
Screen('TextSize',w, 40);

% if sessionNum == 1
%     CenterText(w,sprintf('Please read the Part 4 instructions and continue on your own.') ,white,0,-270);
% else
%     CenterText(w,sprintf('Please read the Part 2 instructions and continue on your own.') ,white,0,-270);
% end

if test_comp == 1 % edit this part so that in the fMRI the begining of the next part would depend on the experimenter and not on the subject
    CenterText(w,sprintf('The demo is done. Questions?') ,white,0,-170);
    Screen('Flip',w);
    WaitSecs(5);
else
    CenterText(w,sprintf('The demo is done.') ,white,0,-270);
    CenterText(w,sprintf('Press any key when you are ready to continue.') ,white,0,-170);
    Screen('Flip',w);
    noresp=1;
    while noresp,
        [keyIsDown,~,~] = KbCheck;
        if keyIsDown && noresp,
            noresp=0;
        end;
    end;
    
end % end if test_comp == 1



fclose(fid1);

outfile=strcat(outputPath, sprintf('/%s_probe_demo_%s.mat', subjectID, timestamp));

% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;

run_info.script_name = mfilename;
clear Images Instructions_image Instructions_image_fmri;
save(outfile);


Screen('CloseAll');
ShowCursor;

toc


