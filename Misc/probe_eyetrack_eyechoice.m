function probe_eyetrack_eyechoice(subjid,test_comp,order, sessNum)

% function probe_boost_TS_Final_fmri_sophis_eye_njmedits_Kbname(subjid,test_comp,order,blockinput)

%=========================================================================
% Probe task code
%=========================================================================

% %---dummy info for testing purposes --------
%subjid='BM2_000';
%test_comp=0;
%order=1;
%sessNum=1;

% %   Exterior files needed for task to run correctly:
% % - - - - - - - - - - - - - - -
% %   'Output/', subjid '_stopGoList.txt'
% %   ['/Onset_files/probe_onset_' num2str(r(1)) '.mat']        where r=1-4
% %   all the contents of     'stim/'     food images
% %   'CenterText.m'

%==============================================
%% 'GLOBAL VARIABLES'
%==============================================
which_block=input('Enter Block 1 or 2 ');

if sessNum == 1 && which_block == 1
    block = 1;
elseif sessNum == 1 && which_block == 2
    block = 2;
    
elseif sessNum == 2 && which_block == 1
    block = 3;
elseif sessNum == 2 && which_block == 2
    block = 4;
end

%   'timestamp'
% - - - - - - - - - - - - - - - - -
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp=[date,'_',hr,'h',min,'m'];
rand('state',sum(100*clock));


%   'set phase times'
% - - - - - - - - - - - - - - - - -
maxtime=2.0;      % 2.0 second limit on each selection
baseline_fixation_dur=2; % Need to modify based on if first few volumes are saved or not
afterrunfixation=6;
fixation_selection_threshold = 0.75; 

tic
%==============================================
%% 'INITIALIZE Screen variables'
%==============================================
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
Screen('Preference', 'TextRenderer', 0);
screennum = max(Screen('Screens'));

pixelSize=32;
% [w] = Screen('OpenWindow',screennum,[],[0 0 640 480],pixelSize);% %debugging screensize
[w] = Screen('OpenWindow',screennum,[],[],pixelSize);

HideCursor;


% Define Colors
% - - - - - - - - - - - - - - - 
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.
green=[0 255 0];
yellow=[255 255 0];

Screen('FillRect', w, black);  % NB: only need to do this once!
Screen('Flip', w);


% text stuffs
% - - - - - - - - - - - - - - -
theFont='Arial';
Screen('TextFont',w,theFont);
Screen('TextSize',w, 40);

% stack locations
% - - - - r- - - - - - - - - - -

[wWidth, wHeight]=Screen('WindowSize', w);
xcenter=wWidth/2;
ycenter=wHeight/2;


stackW=576;
stackH=432;


leftRect=[xcenter-stackW-300 ycenter-stackH/2 xcenter-300 ycenter+stackH/2];
rightRect=[xcenter+300 ycenter-stackH/2 xcenter+stackW+300 ycenter+stackH/2];

penWidth=10;

HideCursor;


%==============================================
%% 'INITIALIZE Eyetracker'
%==============================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializing eye tracking system %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dummymode=0;

% STEP 2
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(w);
% Disable key output to Matlab window:
%%%%%%%%%%%%%ListenChar(2);

el.backgroundcolour = black;
el.backgroundcolour = black;
el.foregroundcolour = white;
el.msgfontcolour    = white;
el.imgtitlecolour   = white;
el.calibrationtargetcolour = el.foregroundcolour;
el.calibrationtargetsize = 5;
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
Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');

% open file to record data to
edfFile='recdata.edf';
Eyelink('Openfile', edfFile);

% STEP 4
% Calibrate the eye tracker
EyelinkDoTrackerSetup(el);

% do a final check of calibration using driftcorrection
EyelinkDoDriftCorrection(el);

% STEP 5
% start recording eye position
Eyelink('StartRecording');
% record a few samples before we actually start displaying
WaitSecs(0.1);

%%%%%%%%%%%%%%%%%%%%%%%%%
% Finish Initialization %
%%%%%%%%%%%%%%%%%%%%%%%%%


%==============================================
%% 'ASSIGN response keys'
%==============================================
%KbName('UnifyKeyNames');
%MRI=0;
%switch test_comp
%    case {0,2,3}
%       leftstack='u';
%        rightstack= 'i';
%        badresp='x';
%    case 1
%        leftstack='b';
%        rightstack= 'y';
%        badresp='x';
%end


badresp='x';



%==============================================
%% 'Read in data'
%==============================================

%   'read in sorted file'
% - - - - - - - - - - - - - - - - -
file=dir(['Output/', subjid '_stopGoList*']);
fid=fopen(['Output/', sprintf(file(length(file)).name)]);
data=textscan(fid, '%s %d %d %f %d') ;% these contain everything from the sortbdm
stimname=data{1};
% stimrank=data{2};
bidValue=data{3};


%   'load image arrays'
% - - - - - - - - - - - - - - -
for i=1:length(stimname)
    food_items{i}=imread(sprintf('stim/%s',stimname{i}));
end

%   'load onsets'
% - - - - - - - - - - - - - - -
r=Shuffle(1:2);
onsetlist=load(['Onset_files/probe_onset_' num2str(r(1)) '.mat']);
onsetlist=onsetlist.onsetlist;


%==============================================
%%   'PRE-TRIAL DATA ORGANIZATION'
%==============================================



% determine stimuli to use based on order number
%-----------------------------------------------------------------
switch order
    case 1
        %   comparisons of interest
        % - - - - - - - - - - - - - - -
        HH_HS=[8 11 12 15];
        HH_HG=[9 10 13 14];        
        
        LL_LS=[46 49 50 53];
        LL_LG=[47 48 51 52];
        
        
        %   sanity check comparisons
        % - - - - - - - - - - - - - - -  
        HL_HS=[16 19 20 23];
        HL_LS=[38 41 42 45];

        
        HL_HG=[17 18 21 22];
        HL_LG=[39 40 43 44];       
        
    case 2
        
        %   comparisons of interest
        % - - - - - - - - - - - - - - -
        HH_HS=[9 10 13 14];
        HH_HG=[8 11 12 15];
               
        
        LL_LS=[47 48 51 52];
        LL_LG=[46 49 50 53];
        
        
        
        %   sanity check comparisons
        % - - - - - - - - - - - - - - -          
        HL_HS=[17 18 21 22];
        HL_LS=[39 40 43 44];

        
        HL_HG=[16 19 20 23];
        HL_LG=[38 41 42 45];
        
end
        

%   add multiple iterations of each item presentation (4 total)
%-----------------------------------------------------------------


%   TRIAL TYPE 1: HighValue Go vs. HighValue NoGo(Stop)
% - - - - - - - - - - - - - - - - - - - - - - - - - - -         
for i=1:4
    for j=1:4
        HH_HS_new(j+(i-1)*4)=HH_HS(i);
        HH_HG_new(j+(i-1)*4)=HH_HG(j);
    end
end
[shuffle_HH_HS_new,shuff_HH_HS_new_ind]=Shuffle(HH_HS_new);
shuffle_HH_HG_new=HH_HG_new(shuff_HH_HS_new_ind);
        
 

%   TRIAL TYPE 2: LowValue Go vs. LowValue NoGo(Stop)
% - - - - - - - - - - - - - - - - - - - - - - - - - - -             
for i=1:4
    for j=1:4
        LL_LS_new(j+(i-1)*4)=LL_LS(i);
        LL_LG_new(j+(i-1)*4)=LL_LG(j);
    end
end
[shuffle_LL_LS_new,shuff_LL_LS_new_ind]=Shuffle(LL_LS_new);
shuffle_LL_LG_new=LL_LG_new(shuff_LL_LS_new_ind);        


%   TRIAL TYPE 3: HighValue NoGo(Stop) vs. LowValue NoGo(Stop)
% - - - - - - - - - - - - - - - - - - - - - - - - - - -       
 for i=1:4
    for j=1:4
        HL_HS_new(j+(i-1)*4)=HL_HS(i);
        HL_LS_new(j+(i-1)*4)=HL_LS(j);
    end
end
[shuffle_HL_HS_new,shuff_HL_HS_new_ind]=Shuffle(HL_HS_new);
shuffle_HL_LS_new=HL_LS_new(shuff_HL_HS_new_ind);



%   TRIAL TYPE 4: HighValue Go vs. LowValue Go
% - - - - - - - - - - - - - - - - - - - - - - - - - - -     
for i=1:4
    for j=1:4
        HL_HG_new(j+(i-1)*4)=HL_HG(i);
        HL_LG_new(j+(i-1)*4)=HL_LG(j);
    end
end
[shuffle_HL_HG_new,shuff_HL_HG_new_ind]=Shuffle(HL_HG_new);
shuffle_HL_LG_new=HL_LG_new(shuff_HL_HG_new_ind);



%   randomize all possible comparisons for all trial types
%-----------------------------------------------------------------
lefthigh=cell(1,2);
stimnum1=cell(1,2);
stimnum2=cell(1,2);
leftname=cell(1,2);
rightname=cell(1,2);
pairtype=cell(1,2);


pairtype{block}= Shuffle([ 1 1 1 1 1 1 1 1  1 1 1 1 1 1 1 1  2 2 2 2 2 2 2 2  2 2 2 2 2 2 2 2  3 3 3 3 3 3 3 3  3 3 3 3 3 3 3 3  4 4 4 4 4 4 4 4  4 4 4 4 4 4 4 4 ]);   
lefthigh{block}=Shuffle([  1 1 1 1 1 1 1 1  0 0 0 0 0 0 0 0  1 1 1 1 1 1 1 1  0 0 0 0 0 0 0 0  1 1 1 1 1 1 1 1  0 0 0 0 0 0 0 0  1 1 1 1 1 1 1 1  0 0 0 0 0 0 0 0 ]);

HH_HS=shuffle_HH_HS_new;
HH_HG=shuffle_HH_HG_new;    
LL_LS=shuffle_LL_LS_new;    
LL_LG=shuffle_LL_LG_new;

HL_HG=shuffle_HL_HG_new;
HL_LG=shuffle_HL_LG_new;    
HL_LS=shuffle_HL_LS_new;
HL_HS=shuffle_HL_HS_new;

HH=1;
LL=1;
HL_S=1;
HL_G=1;

total_num_trials = length(pairtype{block});
for i=1:total_num_trials % trial num within block
    switch pairtype{block}(i)
        case 1 
            
            % HighValue Go vs. HighValue NoGo(Stop)
            % - - - - - - - - - - - - - - - - - - -

            stimnum1{block}(i)=HH_HS(HH);
            stimnum2{block}(i)=HH_HG(HH);
            HH=HH+1;
            if lefthigh{block}(i)==1
                leftname{block}(i)=stimname(stimnum1{block}(i));
                rightname{block}(i)=stimname(stimnum2{block}(i));
            else
                leftname{block}(i)=stimname(stimnum2{block}(i));
                rightname{block}(i)=stimname(stimnum1{block}(i));
            end
            
        case 2 
            
            % LowValue Go vs. LowValue NoGo(Stop)
            % - - - - - - - - - - - - - - - - - - -
            
            stimnum1{block}(i)=LL_LS(LL);
            stimnum2{block}(i)=LL_LG(LL);
            LL=LL+1;
            if lefthigh{block}(i)==1
                leftname{block}(i)=stimname(stimnum1{block}(i));
                rightname{block}(i)=stimname(stimnum2{block}(i));
            else
                leftname{block}(i)=stimname(stimnum2{block}(i));
                rightname{block}(i)=stimname(stimnum1{block}(i));
            end
            
        case 3 
            
            % HighValue NoGo(Stop) vs. LowValue NoGo(Stop)
            % - - - - - - - - - - - - - - - - - - -
            
            stimnum1{block}(i)=HL_HS(HL_S);
            stimnum2{block}(i)=HL_LS(HL_S);
            HL_S=HL_S+1;
            if lefthigh{block}(i)==1
                leftname{block}(i)=stimname(stimnum1{block}(i));
                rightname{block}(i)=stimname(stimnum2{block}(i));
            else
                leftname{block}(i)=stimname(stimnum2{block}(i));
                rightname{block}(i)=stimname(stimnum1{block}(i));
            end

        case 4 
            
            % HighValue Go vs. LowValue Go
            % - - - - - - - - - - - - - - - - - - -
            
            stimnum1{block}(i)=HL_HG(HL_G);
            stimnum2{block}(i)=HL_LG(HL_G);
            HL_G=HL_G+1;
            if lefthigh{block}(i)==1
                leftname{block}(i)=stimname(stimnum1{block}(i));
                rightname{block}(i)=stimname(stimnum2{block}(i));
            else
                leftname{block}(i)=stimname(stimnum2{block}(i));
                rightname{block}(i)=stimname(stimnum1{block}(i));
            end

    end %switch pairtype

end %for i=1=total_num_trials


%==============================================
%% 'Write output file header'
%==============================================

fid1=fopen(['Output/' subjid sprintf('_probe_block_%d_',block) timestamp '.txt'], 'a');
fprintf(fid1,'subjid scanner order block runtrial onsettime ImageLeft ImageRight TypeLeft TypeRight IsLefthigh Response PairType Outcome RT bidLeft bidRight \n'); %write the header line

%==============================================
%% 'Display Main Instructions'
%==============================================
KbQueueCreate;
Screen('TextSize',w, 40); 

%%% While they are waiting for the trigger
if test_comp==1
    Screen('TextSize',w, 60);
    CenterText(w,'PART 4:', white,0,-325);
    
    Screen('TextSize',w, 40);
    CenterText(w,'In this part two pictures of food items will be presented on the Screen.', white,0,-270);
    CenterText(w,'For each trial, we want you to choose one of the items using only your eyes.', white,0,-215);
    CenterText(w,'You will have 2 seconds to make your choice on each trial, so please', white,0,-160);
    CenterText(w,'try to make your choice quickly.', white,0,-105);
    CenterText(w,'At the end of this part we will choose one trial at random and', white,0,-50);
    CenterText(w,'honor your choice on that trial and give you the food item.', white,0,5);
    CenterText(w,'Focus your eyes on the left or right items respectively.', white,0,60);
    CenterText(w,'Waiting for trigger...GET READY....', white, 0, 180);

    escapeKey = KbName('t');
    while 1
        [keyIsDown,secs,keyCode] = KbCheck(-1); 
        if keyIsDown && keyCode(escapeKey)
            break;
        end
    end

    DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected
else
    Screen('TextSize',w, 60);
    if block == 1 || block == 2
        CenterText(w,'PART 4:', white,0,-500);   
    else
        CenterText(w,'PART 2:', white,0,-500);  
    end
    
    Screen('TextSize',w, 40);
    CenterText(w,'In this part two pictures of food items will be presented on the Screen.', white,0,-380);
    CenterText(w,'For each trial, we want you to choose one of the items using only your eyes.', white,0,-320);
    CenterText(w,'You will have 2 seconds to make your choice on each trial, so please', white,0,-260);
    CenterText(w,'try to make your choice quickly.', white,0,-200);
    CenterText(w,'At the end of this part we will choose one trial at random and', white,0,-140);
    CenterText(w,'honor your choice on that trial and give you the food item.', white,0,-80);
    CenterText(w,'Focus your eyes on the the left or right items respectively.', white,0,-20);
    CenterText(w,'This is NOT a demo.', white,0,100);
    CenterText(w,'Press any key to continue', green,0,160);
    
    Screen('Flip',w);

    noresp=1;
    while noresp,
        [keyIsDown] = KbCheck(-1);%deviceNumber=keyboard
        if keyIsDown && noresp,
            noresp=0;
        end;
    end;
end


%   baseline fixation cross
% - - - - - - - - - - - - - 
prebaseline=GetSecs;
% baseline fixation - currently 10 seconds = 4*Volumes (2.5 TR)
while GetSecs < prebaseline+baseline_fixation_dur
    %    Screen(w,'Flip', anchor);
    CenterText(w,'+', white,0,0);
    Screen('TextSize',w, 60);
    Screen(w,'Flip');
    
end
postbaseline=GetSecs;
baseline_fixation= postbaseline- prebaseline;


% STEP 5 of Eyetracker Initialization
% start recording eye position
% - - - - - - - - - - - - - 
Eyelink('StartRecording');
WaitSecs(.05);
Eyelink('Message', 'SYNCTIME after fixations'); % mark start time in file

if ~dummymode 
    eye_used = Eyelink('EyeAvailable');
    if eye_used == -1
        fprintf('Eyelink aborted - could not find which eye being used.\n');
        cleanup;
    end
end

% Option to recolor rectangles to yellow when the subject hovers over them (1 for on)
% Otherwise, only recolored green upon choice, no rectangle when hovered
recolor_rectangles_on_hover = 1;

% DEBUGGING: displays eyeposition. TURN THIS OFF when not needed because
% it is costly
eyepos_debug = 1;

%==============================================
%% 'Run Trials'
%==============================================

% Eyelink msg
% - - - - - - - 
runtrial=1;
runStart=GetSecs;
Eyelink('Message',strcat('runStart=',num2str(runStart)));
KbQueueCreate;

miss_count = 0;
    
for trial=1:total_num_trials
%for trial=1:2

    % Eyelink msg
    % - - - - - - - 
    trialmessage=strcat('trial ',num2str(trial));
    Eyelink('Message',trialmessage);        

    % initial box outline colors
    % - - - - - - - 
    colorleft=black;
    colorright=black;
    out=999;
    
    %-----------------------------------------------------------------
    % display images
    %-----------------------------------------------------------------
    if lefthigh{block}(trial)==1
        Screen('PutImage',w,food_items{stimnum1{block}(trial)}, leftRect);
        Screen('PutImage',w,food_items{stimnum2{block}(trial)}, rightRect);
    else
        Screen('PutImage',w,food_items{stimnum2{block}(trial)}, leftRect);
        Screen('PutImage',w,food_items{stimnum1{block}(trial)}, rightRect);
    end
    CenterText(w,'+', white,0,0);
    StimOnset=Screen(w,'Flip', runStart+onsetlist(runtrial)+baseline_fixation);
%     StimOnset=Screen(w,'Flip');
    
    KbQueueStart;
    
    % Eyelink msg
    % - - - - - - - 
    onsetmessage=num2str(StimOnset-runStart);
    Eyelink('Message',onsetmessage);


    %-----------------------------------------------------------------
    % get fixation response
    % decision = look at object > fixation_duration threshold
    %-----------------------------------------------------------------

    noresp=1;
    goodresp=0; 
    trial_time_fixated_right = 0;
    trial_time_fixated_left = 0;
    trial_time_unfixated = 0;
    trial_num_left_fixations = 0;
    trial_num_right_fixations = 0;
    [current_area, xpos, ypos] = get_current_fixation_area(dummymode,el,eye_used,leftRect,rightRect);
    last_area=current_area;
    fixation_onset_time=GetSecs;
    Eyelink('Message',['initial fixation at ' current_area]);
    while noresp

        % get eye position
        [current_area, xpos, ypos] = get_current_fixation_area(dummymode,el,eye_used,leftRect,rightRect);
        

        % if it's in an area it wasn't in last time we checked, 
        % get the time it started looking in that area
        % also redisplay screen with recolored rectangles, report to output
        
        % should we check if it had an ENDSACC here to ensure its a
        % fixation, or is its presence in the area sufficient?
        if current_area~=last_area

            % update trial fixation timings, to report to output
            if(last_area==0)
                trial_time_unfixated = trial_time_unfixated + (GetSecs-fixation_onset_time);
            elseif(last_area==1)
                trial_time_fixated_right = trial_time_fixated_right + (GetSecs-fixation_onset_time);
                %
            else
                trial_time_fixated_left = trial_time_fixated_left + (GetSecs-fixation_onset_time);
            end

            fixation_onset_time=GetSecs; 

            outstr=['eye area from ' last_area ' to ' current_area ' fixation duration of ' num2str(GetSecs-fixation_onset_time)]; 
            Eyelink('Message',outstr);
            
            % to color rectangles for choice
            if recolor_rectangles_on_hover
                if current_area=='l'
                    colorleft=yellow;
                    colorright=black;
                elseif current_area=='r'
                    colorleft=black;
                    colorright=yellow;
                else
                    colorleft=black;
                    colorright=black;
                end
                

                % redraw the screen with changes to rectangle colors
                % if eyepos_debug, this is unnecessary, since redraws 
                % would be happening constantly
                if ~eyepos_debug
                    CenterText(w,'+', white,0,0);
                    if lefthigh{block}(trial)==1
                        Screen('PutImage',w,food_items{stimnum1{block}(trial)}, leftRect);
                        Screen('PutImage',w,food_items{stimnum2{block}(trial)}, rightRect);
                    else
                        Screen('PutImage',w,food_items{stimnum2{block}(trial)}, leftRect);
                        Screen('PutImage',w,food_items{stimnum1{block}(trial)}, rightRect);
                    end
                    Screen('FrameRect', w, colorleft, leftRect, penWidth);
                    Screen('FrameRect', w, colorright, rightRect, penWidth);
                    Screen('Flip',w,0);
                end
            end
        end

        last_area = current_area;
        
        if eyepos_debug
            CenterText(w,'+', white,0,0);
            if lefthigh{block}(trial)==1
                Screen('PutImage',w,food_items{stimnum1{block}(trial)}, leftRect);
                Screen('PutImage',w,food_items{stimnum2{block}(trial)}, rightRect);
            else
                Screen('PutImage',w,food_items{stimnum2{block}(trial)}, leftRect);
                Screen('PutImage',w,food_items{stimnum1{block}(trial)}, rightRect);
            end
            Screen('FrameRect', w, colorleft, leftRect, penWidth);
            Screen('FrameRect', w, colorright, rightRect, penWidth);

            % must come after rectangle drawing or else rect will
            % overshadow eye_oval
            eye_oval = [xpos-10 ypos-10 xpos+10 ypos+10];
            Screen('FrameOval',w,white,eye_oval,penWidth);
            Screen('Flip',w,0);
        end

        fixation_duration = GetSecs-fixation_onset_time;
        % check if they've been looking at an image for more than the decision threshold time
        if current_area~='n' && fixation_duration >= fixation_selection_threshold
            if current_area=='l'
                choice = 'u';
            elseif current_area=='r'
                choice = 'i';
            end
            noresp=0;
            goodresp=1;
            respTime=GetSecs-StimOnset;
            % fixation duration should always approximately equal fixation_duration_threshold
            outstr = ['Chose ' current_area ' after fixation of ' num2str(fixation_duration) ' seconds.\n'];
            Eyelink('Message',outstr);

            % make final update to trial fixation timings, to report to output
            if(current_area==0)
                trial_time_unfixated = trial_time_unfixated + fixation_duration;
            elseif(current_area==1)
                trial_time_fixated_right = trial_time_fixated_right + fixation_duration;
            else
                trial_time_fixated_left = trial_time_fixated_left + fixation_duration;
            end

        end

        % check for reaching time limit
        if noresp && GetSecs-runStart >= onsetlist(runtrial)+baseline_fixation+maxtime
            noresp=0;
            respTime=maxtime;
            choice=badresp;
            Eyelink('Message','Time limit reached; no choice made.\n');

            % make final update to trial fixation timings, to report to output
            if(current_area==0)
                trial_time_unfixated = trial_time_unfixated + fixation_duration;
            elseif(current_area==1)
                trial_time_fixated_right = trial_time_fixated_right + fixation_duration;
            else
                trial_time_fixated_left = trial_time_fixated_left + fixation_duration;
            end

        end
    end

    %-----------------------------------------------------------------
    % determine what bid to highlight
    %-----------------------------------------------------------------

    switch choice
        case 'u'
            colorleft=green;
            if lefthigh{block}(trial)==0
                out=1;
            else
                out=0;
            end
        case 'i'
            colorright=green;
            if lefthigh{block}(trial)==1
                out=1;
            else
                out=0;
            end
    end
    if goodresp==1
        if lefthigh{block}(trial)==1
            Screen('PutImage',w,food_items{stimnum1{block}(trial)}, leftRect);
            Screen('PutImage',w,food_items{stimnum2{block}(trial)}, rightRect);
        else
            Screen('PutImage',w,food_items{stimnum2{block}(trial)}, leftRect);
            Screen('PutImage',w,food_items{stimnum1{block}(trial)}, rightRect);
        end
        Screen('FrameRect', w, colorleft, leftRect, penWidth);
        Screen('FrameRect', w, colorright, rightRect, penWidth);
        CenterText(w,'+', white,0,0);
        Screen(w,'Flip',runStart+onsetlist(trial)+respTime+baseline_fixation);

    else
        miss_count = miss_count + 1;
        Screen('DrawText', w, 'You must respond faster!', xcenter-300, ycenter, white);
        Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime+baseline_fixation);
    end

    %-----------------------------------------------------------------
    % show fixation ITI
    %-----------------------------------------------------------------

    CenterText(w,'+', white,0,0);
    Screen(w,'Flip',runStart+onsetlist(runtrial)+respTime+.5+baseline_fixation);

    
    % Eyelink msg
    % - - - - - - - 
    fixcrosstime = strcat('fixcrosstime=',num2str(runStart+onsetlist(runtrial)+respTime+.5+baseline_fixation));
    Eyelink('Message',fixcrosstime);
    
    if goodresp ~= 1
        respTime=999;
    end



    %-----------------------------------------------------------------
    % write to output file
    %-----------------------------------------------------------------
    if lefthigh{block}(trial)==1
        fprintf(fid1,'%s %d %d %d %d %d %s %s %d %d %d %s %d %d %.2f %.2f %.2f \n', subjid, test_comp, order, block, runtrial, StimOnset-runStart, char(leftname{block}(trial)), char(rightname{block}(trial)), stimnum1{block}(trial), stimnum2{block}(trial), lefthigh{block}(trial), choice, pairtype{block}(trial), out, respTime*1000, bidValue(stimnum1{block}(trial)), bidValue(stimnum2{block}(trial)));
    else
        fprintf(fid1,'%s %d %d %d %d %d %s %s %d %d %d %s %d %d %.2f %.2f %.2f \n', subjid, test_comp, order, block, runtrial, StimOnset-runStart, char(leftname{block}(trial)), char(rightname{block}(trial)), stimnum2{block}(trial), stimnum1{block}(trial), lefthigh{block}(trial), choice, pairtype{block}(trial), out, respTime*1000, bidValue(stimnum2{block}(trial)), bidValue(stimnum1{block}(trial)));
    end

    %printf('left: %s right: %s none: %s',trial_time_fixated_left,trial_time_fixated_right,trial_time_unfixated);
    
    runtrial=runtrial+1;
    KbQueueFlush;
    
end % loop through trials

fclose(fid1);
EndofBlock1Time=GetSecs;

Postexperiment=GetSecs;
while GetSecs < Postexperiment+afterrunfixation;
    CenterText(w,'+', white,0,0);
    Screen('TextSize',w, 60);
    Screen(w,'Flip');

end


if block == 1
    WaitSecs(2);
    Screen('FillRect', w, black); 
    Screen('TextSize',w, 40);
    CenterText(w,sprintf('In a moment we will complete another run of the same task') ,white,0,-170);
    Screen('Flip',w);
elseif block == 2
    WaitSecs(2);
    Screen('FillRect', w, black); 
    Screen('TextSize',w, 40);
    CenterText(w,sprintf('Please read the Part 5 instructions and continue on your own.') ,white,0,-170);
    Screen('Flip',w);
elseif block == 3
    WaitSecs(2);
    Screen('FillRect', w, black); 
    Screen('TextSize',w, 40);
    CenterText(w,sprintf('In a moment we will complete another run of the same task') ,white,0,-170);
    Screen('Flip',w);
elseif block == 4
    WaitSecs(2);
    Screen('FillRect', w, black); 
    Screen('TextSize',w, 40);
    CenterText(w,sprintf('Please read the Part 3 instructions and continue on your own.') ,white,0,-170);
    Screen('Flip',w);
end

%==============================================
%% 'BLOCK over, close out and save data'
%==============================================

%---------------------------------------------------------------
%   close out eyetracker
%---------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%
% finishing eye tracking %
%%%%%%%%%%%%%%%%%%%%%%%%%%

% STEP 7
% finish up: stop recording eye-movements,
% close graphics window, close data file and shut down tracker
Eyelink('StopRecording');
WaitSecs(.1);
Eyelink('CloseFile');


% download data file
% - - - - - - - - - - - - 
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
    movefile('recdata.edf',strcat('Output/', subjid,'_',timestamp,'.edf'));
end;


WaitSecs(3);





%---------------------------------------------------------------
% create a data structure with info about the run
%---------------------------------------------------------------
outfile=strcat('Output/', sprintf('%s_probe_block_%d_%s.mat',subjid,block,timestamp));

% create a data structure with info about the run
run_info.subject=subjid;
run_info.date=date;
run_info.outfile=outfile;

run_info.script_name=mfilename;
clear food_items ;
save(outfile);



toc
if block == 1 || block ==3
    ShowCursor;
    Screen('closeall');
end

% report how much of the data was missed
fprintf(strcat('Successful eye selection rate: ',num2str(((total_num_trials-miss_count)/total_num_trials)*100),' percent\n'))

end

% Cleanup routine:
function cleanup

% finish up: stop recording eye-movements,
% close graphics window, close data file and shut down tracker
Eyelink('Stoprecording');
Eyelink('CloseFile');
Eyelink('Shutdown');

% Close window:
Screen('CloseAll');

% Restore keyboard output to Matlab:
ListenChar(0);
ShowCursor;
end

% returns "l" for left, "r" for right, or "n" for none. Also returns x,y
% positions in case eyepos_debug is being used
function [current_area, xpos, ypos] = get_current_fixation_area(dummymode,el,eye_used,leftRect,rightRect)
    current_area = 'n';
    xpos = 0;
    ypos = 0;
    if ~dummymode 
        evt=Eyelink('NewestFloatSample');
        x=evt.gx(eye_used+1);
        y=evt.gy(eye_used+1);
        if(x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0)
            xpos=x;
            ypos=y;
        end
    else % in dummy mode use mousecoordinates
        [xpos,ypos] = GetMouse;
    end

    % check what area the eye is in
    if IsInRect(xpos,ypos,leftRect)
       current_area='l';
    elseif IsInRect(xpos,ypos,rightRect)
       current_area='r';
    else
       current_area='n';
    end
    return
end