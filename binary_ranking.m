
function binary_ranking(subjectID,test_comp,mainPath)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ======================== by Tom Salomon 2014-2015 =======================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% Ranking using a set of binary choices.
% This function was written based on the probe code. It is used to rank 60
% different items, based on subject's selection. In each trial two images
% will appear on screen, and the subject is asked to choose one, using the
% 'u' and 'i' keys. Each stimulus will be presented exactly 10 times, each
% time in a different comparison, for a total number of 300 unique
% comparisons.
% Finally, Colley ranking code is run on the subject's choices to create a
% ranking list of all 60 item.

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ---------------- FUNCTIONS REQUIRED TO RUN PROPERLY: ----------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % %   'random_stimlist_generator'
% % %   'colley'

%=========================================================================
%% dummy info for testing purposes
%=========================================================================

% subjectID='BM2_000';
% test_comp=0;
% path=pwd

%==============================================
%% GLOBAL VARIABLES
%==============================================
% default input
% - - - - - - - - - - - - - - - - -
if nargin<=2
    mainPath=pwd;
    if nargin==1
        test_comp=0;
    end
end

% timestamp
% - - - - - - - - - - - - - - - - -
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp=[date,'_',hr,'h',min,'m'];

% set phase times
% - - - - - - - - - - - - - - - - -
maxtime=2.5;      % 2.5 second limit on each selection
baseline_fixation_dur=0.5; % Need to modify based on if first few volumes are saved or not
afterrunfixation=0.5;
TotalTrialDuration = maxtime + baseline_fixation_dur + afterrunfixation;
tic

% essential for randomization
rng('shuffle');

%==============================================
%% Read in data
%==============================================

% load image arrays
% - - - - - - - - - - - - - - -
% Read all image files in the 'stim' folder. make sure the ending is suitable
% to your stimuli, and the folder contains only the experiment's 60 images.
stimuli=dir([pwd '/stim/*.jpg' ]);
stimname=struct2cell(rmfield(stimuli,{'date','bytes','isdir','datenum'}));
Images=cell(length(stimname),1);
for i=1:length(stimname)
    Images{i}=imread(sprintf('%s',mainPath,'/stim/',stimname{i}));
end

% Load Hebrew instructions image files
Instructions=dir([mainPath '/Instructions/*binary_ranking.JPG' ]);
Instructions_name=struct2cell(rmfield(Instructions,{'date','bytes','isdir','datenum'}));
Instructions_image=imread([mainPath '/Instructions/' sprintf(Instructions_name{1})]);

%==============================================
%% 'INITIALIZE Screen variables'
%==============================================
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
screennum = max(Screen('Screens'));

pixelSize=32;
% [w] = Screen('OpenWindow',screennum,[],[0 0 640 480],pixelSize);% %debugging screensize
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

% Define Colors
% - - - - - - - - - - - - - - -
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
green=[0 255 0];

Screen('FillRect', w, black);  % NB: only need to do this once!
Screen('Flip', w);


% text stuffs
% - - - - - - - - - - - - - - -
theFont='Arial';
Screen('TextFont',w,theFont);
Screen('TextSize',w, 40);

% Define image scale - Change according to your stimuli
% - - - - - - - - - - - - - - -
stackH= size(Images{1},1);
stackW= size(Images{1},2);

% Frame and stack properties
% - - - - - - - - - - - - - - -
[wWidth, wHeight]=Screen('WindowSize', w);
xcenter=wWidth/2;
ycenter=wHeight/2;
xDist = 300; % distance from center in the x axis. can be changed to adjust to smaller screens
leftRect=[xcenter-stackW-xDist ycenter-stackH/2 xcenter-xDist ycenter+stackH/2]; % left stack location
rightRect=[xcenter+xDist ycenter-stackH/2 xcenter+stackW+xDist ycenter+stackH/2]; % right stack location
penWidth=10; % frame width

HideCursor;

%==============================================
%% 'ASSIGN response keys'
%==============================================
KbName('UnifyKeyNames');
switch test_comp
    case {0,2,3}
        leftstack='u';
        rightstack= 'i';
        badresp='x';
    case 1
        leftstack='b';
        rightstack= 'y';
        badresp='x';
end

%==============================================
%%   'PRE-TRIAL DATA ORGANIZATION'
%==============================================
% Stimuli lists
% - - - - - - - - - - - - - - -
number_of_stimuli=length(stimname); % number of stimuli
number_of_trials=300; % desired number of trials (number of unique comparisons)
% number_of_trials=30; % for debugging

% Define onsets
% - - - - - - - - - - - - - - -
onsetlist=0:TotalTrialDuration:TotalTrialDuration*number_of_trials;

% IMPORTANT NOTE: every stimulus will be presented exactly 2*number_of_trials/n times. Therefore, number_of_trials should be a multiple of n/2. e.g if n=60, number_of_trials can be 30,60,90,120....
% ==============                                                                                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[shuffle_stimlist1,shuffle_stimlist2]=random_stimlist_generator(number_of_stimuli,number_of_trials);

% Colley's ranking analysis variables
% - - - - - - - - - - - - - - -
N=zeros(number_of_stimuli,3); %create the N matrix of (win,loses,total) for each stimulus (each row represent a specific stimulus). To be used in Colley's ranking
T=zeros(number_of_stimuli,number_of_stimuli); %create the T symetric matrix of "competitions"  (each row represent a specific stimulus). T(a,b)=T(b,a)=-1 means a "competition" had taken place between stimuli a&b. To be used in Colley's ranking
for stimulus=1:number_of_stimuli
    T(stimulus,shuffle_stimlist1(shuffle_stimlist2==stimulus))=-1;
    T(shuffle_stimlist1(shuffle_stimlist2==stimulus),stimulus)=-1;
    T(stimulus,shuffle_stimlist2(shuffle_stimlist1==stimulus))=-1;
    T(shuffle_stimlist2(shuffle_stimlist1==stimulus),stimulus)=-1;
    N(stimulus,3)=(sum(shuffle_stimlist1==stimulus)+sum(shuffle_stimlist2==stimulus));
end

%-----------------------------------------------------------------
%% 'Write output file header'
%-----------------------------------------------------------------
fid1=fopen([mainPath '/Output/' subjectID '_binary_ranking_' timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\truntrial\tonsettime\tImageLeft\tImageRight\tStimNumLeft\tStimNumRight\tResponse\tOutcome\tRT\n'); %write the header line

%-----------------------------------------------------------------
%% Initializing eye tracking system %
%-----------------------------------------------------------------
use_eyetracker=0; % set to 1/0 to turn on/off eyetracker functions
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
    edfFile='Ranking.edf';
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
%==============================================
%% 'Display Main Instructions'
%==============================================
KbQueueCreate;
% Screen('TextSize',w, 60);
% CenterText(w,'PART 1', white,0,-500);
%
% Screen('TextSize',w, 40);
% CenterText(w,'In this part two pictures of faces will be presented on the Screen.', white,0,-270);
% CenterText(w,'For each trial, we want you to choose one of the faces using the keyboard.', white,0,-215);
% CenterText(w,'You will have 2.5 seconds to make your choice on each trial, so please', white,0,-160);
% CenterText(w,'try to make your choice quickly.', white,0,-105);
% % small gap
% CenterText(w,'Press the `u` and `i` keys for the left and right items respectively.', white,0,60);
% CenterText(w,'This is NOT a demo. Press any key to start.', green, 0, 180);
%
% Screen('Flip',w);

Screen('PutImage',w,Instructions_image);
Screen(w,'Flip');


noresp=1;
while noresp,
    [keyIsDown] = KbCheck(-1); % deviceNumber=keyboard
    if keyIsDown && noresp,
        noresp=0;
    end;
end;

% baseline fixation cross
% - - - - - - - - - - - - -
prebaseline = GetSecs;
% baseline fixation - currently 10 seconds = 4*Volumes (2.5 TR)
while GetSecs < prebaseline+baseline_fixation_dur
    %    Screen(w,'Flip', anchor);
    CenterText(w,'+', white,0,-60);
    Screen('TextSize',w, 60);
    Screen(w,'Flip');
end
postbaseline = GetSecs;
baseline_fixation = postbaseline - prebaseline;

%==============================================
%% 'Run Trials'
%==============================================
runtrial=1;
runStart=GetSecs;

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

for trial=1:number_of_trials
    
    chose_rand=rand; % randomly chose left/right location od stimuli
    if chose_rand<=0.5
        leftname=stimname(shuffle_stimlist1(trial));
        rightname=stimname(shuffle_stimlist2(trial));
    else
        leftname=stimname(shuffle_stimlist2(trial));
        rightname=stimname(shuffle_stimlist1(trial));
    end
    
    out=999;
    
    %-----------------------------------------------------------------
    % display images
    %-----------------------------------------------------------------
    if chose_rand<=0.5
        Screen('PutImage',w,Images{shuffle_stimlist1(trial)}, leftRect);
        Screen('PutImage',w,Images{shuffle_stimlist2(trial)}, rightRect);
        eyelink_message=['trial ',num2str(trial),', StimLeft: ',stimname{shuffle_stimlist1(trial)},' StimRight: ',stimname{shuffle_stimlist2(trial)},' time: ',num2str(GetSecs)];
    else
        Screen('PutImage',w,Images{shuffle_stimlist2(trial)}, leftRect);
        Screen('PutImage',w,Images{shuffle_stimlist1(trial)}, rightRect);
        eyelink_message=['trial ',num2str(trial),', StimLeft: ',stimname{shuffle_stimlist2(trial)},' StimRight: ',stimname{shuffle_stimlist1(trial)},' time: ',num2str(GetSecs)];
    end

    if use_eyetracker
        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message',eyelink_message);
    end
    
    CenterText(w,'+', white,0,-60);
    StimOnset=Screen(w,'Flip', runStart+onsetlist(runtrial)+baseline_fixation);
    
    
    %-----------------------------------------------------------------
    % get response
    %-----------------------------------------------------------------
    KbQueueFlush;
    KbQueueStart;
    noresp=1;
    goodresp=0;
    while noresp
        
        % check for response
        [keyIsDown, firstPress] = KbQueueCheck;
        
        if keyIsDown && noresp
            if use_eyetracker
                %   Eyelink MSG
                % ---------------------------
                Eyelink('Message',['trial: ',num2str(trail),' Press_time: ',num2str(GetSecs)]);
            end
            
            keyPressed=KbName(firstPress);
            
            if ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                keyPressed=char(keyPressed);
                keyPressed=keyPressed(1);
            end
            
            switch keyPressed
                case leftstack
                    respTime=firstPress(KbName(leftstack))-StimOnset;
                    noresp=0;
                    goodresp=1;
                case rightstack
                    respTime=firstPress(KbName(rightstack))-StimOnset;
                    noresp=0;
                    goodresp=1;
            end
        end
        
        % check for reaching time limit
        if noresp && GetSecs-runStart >= onsetlist(runtrial)+baseline_fixation+maxtime
            noresp=0;
            keyPressed=badresp;
            respTime=maxtime;
        end
    end
    
    %-----------------------------------------------------------------
    % determine what bid to highlight
    %-----------------------------------------------------------------
    
    switch keyPressed
        case leftstack
            if shuffle_stimlist2(trial)==0
                out=1;
            else
                out=0;
            end
        case rightstack
            if shuffle_stimlist2(trial)==1
                out=1;
            else
                out=0;
            end
    end
    
    if goodresp==1 % if responded: add green rectangle around selected image
        if chose_rand<=0.5
            Screen('PutImage',w,Images{shuffle_stimlist1(trial)}, leftRect);
            Screen('PutImage',w,Images{shuffle_stimlist2(trial)}, rightRect);
        else
            Screen('PutImage',w,Images{shuffle_stimlist2(trial)}, leftRect);
            Screen('PutImage',w,Images{shuffle_stimlist1(trial)}, rightRect);
        end
        
        if keyPressed==leftstack
            Screen('FrameRect', w, green, leftRect, penWidth);
        elseif keyPressed==rightstack
            Screen('FrameRect', w, green, rightRect, penWidth);
        end
        
        CenterText(w,'+', white,0,-60);
        Screen(w,'Flip',runStart+onsetlist(trial)+respTime+baseline_fixation);
        
        
    else % if did not respond: show text 'You must respond faster!'
        CenterText(w,sprintf('You must respond faster!') ,white,0,0);
        %         Screen('DrawText', w, 'You must respond faster!', xcenter-450, ycenter, white);
        Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime+baseline_fixation);
        if use_eyetracker
            %   Eyelink MSG
            % ---------------------------
            Eyelink('Message',['Respond faster! time: ',num2str(GetSecs)]);
        end
    end
    
    %-----------------------------------------------------------------
    % show fixation ITI
    %-----------------------------------------------------------------
    
    CenterText(w,'+', white,0,-60);
    Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime+.5+baseline_fixation);
    if use_eyetracker
        %   Eyelink MSG
        % ---------------------------
        Eyelink('Message',['Fixation cross time: ',num2str(GetSecs)]);
    end
    
    if goodresp ~= 1
        respTime=999;
        % Colley ranking input - remove ties (no choices) from calculation.
        T(shuffle_stimlist1(trial),shuffle_stimlist2(trial))=0;
        T(shuffle_stimlist2(trial),shuffle_stimlist1(trial))=0;
        N(shuffle_stimlist1(trial),3)=N(shuffle_stimlist1(trial),3)-1;
        N(shuffle_stimlist2(trial),3)=N(shuffle_stimlist2(trial),3)-1;
        
    end
    
    %-----------------------------------------------------------------
    % write to output file
    %-----------------------------------------------------------------
    if chose_rand<=0.5
        fprintf(fid1,'%s\t%d\t%d\t%s\t%s\t%d\t%d\t%s\t%d\t%d\n', subjectID, runtrial, StimOnset-runStart, char(leftname), char(rightname), shuffle_stimlist1(trial), shuffle_stimlist2(trial), keyPressed, out, respTime*1000);
    else
        fprintf(fid1,'%s\t%d\t%d\t%s\t%s\t%d\t%d\t%s\t%d\t%d\n', subjectID, runtrial, StimOnset-runStart, char(leftname), char(rightname), shuffle_stimlist2(trial), shuffle_stimlist1(trial), keyPressed,  out, respTime*1000);
    end
    
    % add trial info to the Colley ranking mats
    if chose_rand<=0.5
        if keyPressed==leftstack
            N(shuffle_stimlist1(trial),1)=N(shuffle_stimlist1(trial),1)+1;
            N(shuffle_stimlist2(trial),2)=N(shuffle_stimlist2(trial),2)+1;
        elseif keyPressed==rightstack
            N(shuffle_stimlist2(trial),1)=N(shuffle_stimlist2(trial),1)+1;
            N(shuffle_stimlist1(trial),2)=N(shuffle_stimlist1(trial),2)+1;
        end
    else
        if keyPressed==rightstack
            N(shuffle_stimlist1(trial),1)=N(shuffle_stimlist1(trial),1)+1;
            N(shuffle_stimlist2(trial),2)=N(shuffle_stimlist2(trial),2)+1;
        elseif keyPressed==leftstack
            N(shuffle_stimlist2(trial),1)=N(shuffle_stimlist2(trial),1)+1;
            N(shuffle_stimlist1(trial),2)=N(shuffle_stimlist1(trial),2)+1;
        end
    end
    
    % end of current trial
    runtrial=runtrial+1;
    KbQueueFlush;
end % loop through trials

fclose(fid1);
Postexperiment=GetSecs;
if use_eyetracker
    %   Eyelink MSG
    % ---------------------------
    Eyelink('Message',['Part end time: ',num2str(GetSecs)]);
end

while GetSecs < Postexperiment+afterrunfixation;
    CenterText(w,'+', white,0,-60);
    Screen('TextSize',w, 60);
    Screen(w,'Flip');
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
        movefile(edfFile,['./Output/', subjectID,'_BinaryRanking_eyetracking_', timestamp,'.edf']);
    end;
end

%-----------------------------------------------------------------
%	display end of part message
%-----------------------------------------------------------------
WaitSecs(2);
Screen('FillRect', w, black);
Screen('TextSize',w, 40);
CenterText(w,sprintf('Thank you! Please call the experimenter.') ,white,0,-170);
Screen('Flip',w);
WaitSecs(3);
Screen('CloseAll');

%---------------------------------------------------------------
% create a data structure with info about the run
%---------------------------------------------------------------
outfile=strcat(mainPath,'/Output/', sprintf('%s_binary_ranking_%s',subjectID,timestamp),'.mat');

% create a data structure with info about the run
run_info.subject=subjectID;
run_info.date=date;
run_info.outfile=outfile;

% Run Colley's ranking
stimuli_ranking=colley(T,N);

fid2=fopen([mainPath,'/Output/' subjectID '_ItemRankingResults_' timestamp '.txt'], 'a');
fprintf(fid2,'Subject\tStimName\tStimNum\tRank\tWins\tLoses\tTotal\n');
for j=1:number_of_stimuli
    fprintf(fid2,'%s\t%s\t%d\t%d\t%d\t%d\t%d\n', subjectID, char(stimname(j)), j, stimuli_ranking(j), N(j,1), N(j,2), N(j,3));
end
fclose(fid2);

run_info.script_name=mfilename;
clear ('Images','Instructions_image');
save(outfile);

KbQueueFlush;

end


