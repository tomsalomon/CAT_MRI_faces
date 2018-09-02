% function recognitionNewOld_Israel(subjectID,test_comp,mainPath,order, sessionNum)

% function recognitionNewOld_Israel(subjectID,test_comp,mainPath,order, sessionNum)

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ==================== by Rotem Botvinik May 2015 ====================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

% This function runs the first part of the memory (recognition) session of the
% boost (cue-approach) task.
% Subjects are presented with the stimuli from the previous sessions (but
% only those that were part of the probe comparisons- as defined hard-coded in this function)
% as well as some items that were not included in the training session, in a random order, and
% should answer whether they recognize each stimuli from the previous
% sessions or not.
% In the next memory (recognition) session, run by the
% 'recognitionGoNoGo_Israel' function, they are presented with the items
% they said were present during the training session, and are asked whether
% each item was paired with a beep (GO item) or not (NOGO item).

% Old stimuli should be located in the folder [mainPath'/stim/']
% New stimuli should be located in the folder [mainPath'/stim/recognitionNew/']

% This version of the function fits the boost version with training only 40
% items!


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % --------- Exterior files needed for task to run correctly: ----------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   'stopGoList_allstim_order%d.txt', order --> Created by the 'sortBdm_Israel' function


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ------------------- Creates the following files: --------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%   ''recognitionNewOld_results' num2str(sessionNum) '_' timestamp '.txt''
%   --> Which includes the variables: trialNum (in the newOld recognition task), index
%   of the item (ABC order, old and than new), name of item, whether the item
%   is old (1) or not (0), the subject's answer (0- no; 1-
%   yes)

%   ''recognitionNewOld' num2str(sessionNum) '_' timestamp '.txt''


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % ------------------- dummy info for testing purposes -------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% subjectID = 'test999';
% order = 1;
% test_comp = 4;
% sessionNum = 1;
% mainPath = '/Users/schonberglabimac1/Documents/BMI_BS_40';

clear all

tic

rng shuffle


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
%         mainPath = pwd;
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




% % Here Be Colors
black = BlackIndex(w); % Should equal 0.
white = WhiteIndex(w); % Should equal 255.
green = [0 255 0];

Screen('FillRect', w, black);  % NB: only need to do this once!
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
Instructions = dir([mainPath '/Instructions/recognitionNewOld.JPG' ]);
Instructions_fmri = dir([mainPath '/Instructions/fmri_recognitionNewOld.JPG' ]);
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
%% 'Assign response keys'
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
%% 'DEFINE stimuli of interest'
%---------------------------------------------------------------

switch order
    case 1
        %   comparisons of interest
        % - - - - - - - - - - - - - - -
        HV_beep =   [7 10 12 13 15 18]; % HV_beep
        HV_nobeep = [8 9 11 14 16 17]; % HV_nobeep
        
        LV_beep =   [44 45 47 50 52 53]; % LV_beep
        LV_nobeep = [43 46 48 49 51 54]; % LV_nobeep
        
        
        %   sanity check comparisons - just NOGO
        % - - - - - - - - - - - - - - 
        sanityHV_nobeep = [5 6]; % HV_nobeep
        sanityLV_nobeep = [55 56]; % LV_nobeep
        
    case 2
        
        %   comparisons of interest
        % - - - - - - - - - - - - - - -
        HV_beep =   [8 9 11 14 16 17]; % HV_beep
        HV_nobeep = [7 10 12 13 15 18]; % HV_nobeep
        
        
        LV_beep =   [43 46 48 49 51 54]; % LV_beep
        LV_nobeep = [44 45 47 50 52 53]; % LV_nobeep
        
                
        %   sanity check comparisons - just NOGO
        % - - - - - - - - - - - - - - -
        sanityHV_nobeep = [5 6]; % HV_nobeep
        sanityLV_nobeep = [55 56]; % LV_nobeep
        
end % end switch order


%---------------------------------------------------------------
%% 'READ data about the stimuli - Go \ NoGo
%---------------------------------------------------------------

%   'Reading in the sorted BDM list - defines which items will be GO\NOGO'
% - - - - - - - - - - - - - - -
file = dir([outputPath '/' subjectID sprintf('_stopGoList_allstim_order%d.txt', order)]);
fid = fopen([outputPath '/' sprintf(file(length(file)).name)]);
vars = textscan(fid, '%s %d %d %f %d') ;% these contain everything from the sortbdm
fclose(fid);

allOldStimName = vars{1};
allGoNoGo = vars{2};
allIsBeep = zeros(length(allGoNoGo),1);
allIsBeep(allGoNoGo == 11 | allGoNoGo == 22) = 1;
allBidInd = vars{3};
% bidValue = vars{4};
oldStimName = allOldStimName([HV_beep HV_nobeep LV_beep LV_nobeep sanityHV_nobeep sanityLV_nobeep]);
% goNoGo = allGoNoGo([HV_beep HV_nobeep LV_beep LV_nobeep]);
isBeep = allIsBeep([HV_beep HV_nobeep LV_beep LV_nobeep   sanityHV_nobeep sanityLV_nobeep]);
bidInd = allBidInd([HV_beep HV_nobeep LV_beep LV_nobeep   sanityHV_nobeep sanityLV_nobeep]);

[oldStimName, indSortedOldStimName] = sort(oldStimName); % sort old stimuli ABC

%---------------------------------------------------------------
%% 'LOAD image arrays'
%---------------------------------------------------------------

newStimName = dir([mainPath '/stim/recognitionNew/*.jpg']); % Read new stimuli

% Read old images to a cell array
imgArraysOld = cell(1,length(oldStimName));
for i = 1:length(oldStimName)
    imgArraysOld{i} = imread([mainPath '/stim/' oldStimName{i}]);
end
Old = ones(length(oldStimName),1);

% Read new images to a cell array
imgArraysNew = cell(1,length(newStimName));
for i = 1:length(newStimName)
    imgArraysNew{i} = imread([mainPath '/stim/recognitionNew/' newStimName(i).name]);
end
New = zeros(length(newStimName),1);

isOld = [Old; New]; % Create an array indicating whether an item is old (1) or not (0)

% Stack size and location
sizeFactor = 1;
stackH= sizeFactor*size(imgArraysOld{1},1);
stackW= sizeFactor*size(imgArraysOld{1},2);
rect = [xcenter-stackW/2 ycenter-stackH/2 xcenter+stackW/2 ycenter+stackH/2];

%---------------------------------------------------------------
%% 'ORGANIZE data about the stimuli - Go \ NoGo
%---------------------------------------------------------------

% Add zeros for the goNoGo, isBeep, bidInd and bidValue of the new items
% - - - - - - - - - - - - - - -

sortedIsBeep = isBeep(indSortedOldStimName);
sortedIsBeep(length(oldStimName)+1:length(oldStimName)+length(newStimName)) = 0;


sortedBidInd = bidInd(indSortedOldStimName);
sortedBidInd(length(oldStimName)+1:length(oldStimName)+length(newStimName)) = 0;

%---------------------------------------------------------------
%% 'SHUFFLE data about the stimuli - Go \ NoGo
%---------------------------------------------------------------

% Merge the old and new lists, and shuffle them

% Add the names of the new stimuli to stimName
stimName = cell(1, length(oldStimName) + length(newStimName));
stimName(1:length(oldStimName)) = oldStimName;

for newStimInd = 1:length(newStimName)
    stimName{length(oldStimName)+newStimInd} = newStimName(newStimInd).name;
end

[shuffledlist, shuffledlistInd] = Shuffle(stimName);
imgArrays = [imgArraysOld imgArraysNew];
imgArrays = imgArrays(shuffledlistInd);
shuffledIsOld = isOld(shuffledlistInd);
shuffledSortedIsBeep = sortedIsBeep(shuffledlistInd);
shuffledSortedBidInd = sortedBidInd(shuffledlistInd);


% r = Shuffle(1:4);
% onsetlist = load(['Onset_files/sweet_salty_onset_' num2str(r(1)) '.mat']);
% onsetlist = onsetlist.onsetlist;

% ListenChar(2); % suppresses terminal ouput

%---------------------------------------------------------------
%% 'Write output file header'
%---------------------------------------------------------------

fid1 = fopen([outputPath '/' subjectID '_recognitionNewOld' num2str(sessionNum) '_' timestamp '.txt'], 'a');
fprintf(fid1,'subjectID\torder\titemIndABC\truntrial\tisOld?\tsubjectAnswer\tonsettime\tName\tresp_choice\tRT\tbidInd\tisBeep?\n'); %write the header line
% Open txt file to write the subject's answers (yes\no)
fid2 = fopen([outputPath '/' subjectID '_recognitionNewOld_results' num2str(sessionNum) '_' timestamp '.txt'], 'a');

%---------------------------------------------------------------
%% 'Display Main Instructions'
%---------------------------------------------------------------

Screen('TextSize',w, 40);
% if sessionNum == 1
%     CenterText(w,'Part 6:',white, 0,-450);
% else
%     CenterText(w,'PART 3:', white,0,-450);
% end
% 
% CenterText(w,'Please think back to the previous tasks you completed.',white, 0, -300);
% CenterText(w,'You will NOT hear any beeps during this part of the experiment.',white, 0, -200);
% 
% if order==1
%     CenterText(w,'Press `u` if this item WAS included in that task (YES).', white,0,-50);
%     CenterText(w,'Press `i` if this item WAS NOT included in that task (NO).', white, 0,50);
%     
% else
%     CenterText(w,'Press `u` if this item WAS NOT included in that task (NO).', white,0,-50);
%     CenterText(w,'Press `i` if this item WAS included in that task (YES).', white, 0,50);
% end
% 
% CenterText(w,'Please press any key to continue.', green,0,300);
% HideCursor; % Make a comment in debugging mode
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
    DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected  
end; % end if test_comp == 1

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
Included = zeros(1, length(stimName)); % An array for the results. 1 represent items that the subject said were present

runStart = GetSecs;

% for trial = 1:6 % for debugging
for trial = 1:length(stimName)
    
    colorright = white;
    colorleft = white;
    
    %-----------------------------------------------------------------
    % display image
    % self-paced; next image will only show after response
    
    Screen('PutImage',w, imgArrays{trial},rect);
    Screen('TextSize',w, 40);
    
    %     if order == 1
    %         Screen('DrawText', w, 'YES', xcenter-350,ycenter+300, white);
    %         Screen('DrawText', w, 'Not included', xcenter+120, ycenter+300, white);
    %     else
    %         Screen('DrawText', w, 'Not included', xcenter-350, ycenter+300, white);
    %         Screen('DrawText', w, 'Included', xcenter+120, ycenter+300, white);
    %     end
    
    if order == 1
        if test_comp == 1
        CenterText(w,'left - Yes',colorleft,-250,300);
        CenterText(w,'right - No',colorright,250,300);   
        else
        CenterText(w,'u - Yes',colorleft,-250,300);
        CenterText(w,'i - No',colorright,250,300);
        end
    else
        if test_comp == 1
        CenterText(w,'left - No',colorleft,-250,300);
        CenterText(w,'right - Yes', colorright,250,300);            
        else
        CenterText(w,'u - No',colorleft,-250,300);
        CenterText(w,'i - Yes', colorright,250,300);
        end
    end
    
    Screen(w,'Flip');
    StimOnset = GetSecs;
    
    KbQueueStart;
    %-----------------------------------------------------------------
    % get response
    
    
    noresp = 1;
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
            if response==leftresp||response==rightresp % A valid response is only 'u' or 'i'
            noresp = 0;
            end
            
        end % end if keyIsDown && noresp
        
    end % end while noresp
    
    
    
    %-----------------------------------------------------------------
    
    % determine what bid to highlight and write the subject's response to
    % the Included array
    if order ==1
        switch response
            case leftresp
                colorleft = green;
                Included(trial) = 1;
            case rightresp
                colorright = green;
        end
    else % order == 2
        switch response
            case leftresp
                colorleft = green;
            case rightresp
                colorright = green;
                Included(trial) = 1;
        end
    end % end if order == 1
    
    %-----------------------------------------------------------------
    % redraw text output with the appropriate colorchanges
    Screen('PutImage',w,imgArrays{trial}, rect);
    Screen('TextSize',w, 40);
    %     if order==1
    %         Screen('DrawText', w, 'Included', xcenter-350,ycenter+300, colorleft);
    %         Screen('DrawText', w, 'Not included', xcenter+120, ycenter+300, colorright);
    %     else
    %         Screen('DrawText', w, 'Not included', xcenter-350, ycenter+300, colorleft);
    %         Screen('DrawText', w, 'Included', xcenter+120, ycenter+300, colorright);
    %     end
    
    if order == 1
        if test_comp == 1
        CenterText(w,'left - Yes',colorleft,-250,300);
        CenterText(w,'right - No',colorright,250,300);   
        else
        CenterText(w,'u - Yes',colorleft,-250,300);
        CenterText(w,'i - No',colorright,250,300);
        end
    else
        if test_comp == 1
        CenterText(w,'left - No',colorleft,-250,300);
        CenterText(w,'right - Yes', colorright,250,300);            
        else
        CenterText(w,'u - No',colorleft,-250,300);
        CenterText(w,'i - Yes', colorright,250,300);
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
    
    %-----------------------------------------------------------------
    % Write to output files
    
    fprintf(fid1,'%s\t %d\t %d\t %d\t %d\t %d\t %d\t %s\t %s\t %d\t %d\t %d\t \n', subjectID, order, shuffledlistInd(trial), trial, shuffledIsOld(trial), Included(trial), StimOnset-runStart, shuffledlist{trial}, response, respTime, shuffledSortedBidInd(trial), shuffledSortedIsBeep(trial));
    fprintf(fid2,'%d\t %d\t %s\t %d\t %d\t %d\t %d\t \n', trial, shuffledlistInd(trial), shuffledlist{trial}, shuffledIsOld(trial), Included(trial), shuffledSortedBidInd(trial), shuffledSortedIsBeep(trial));
    
    KbQueueFlush;
    
    
end % end loop for trial = 1:length(food_images);

% Close open files
fclose(fid1);
fclose(fid2);


% Save variables to mat file
outfile = strcat(outputPath,'/', sprintf('%s_recognitionOldNew_%s.mat',subjectID, timestamp));

% create a data structure with info about the run
run_info.subject = subjectID;
run_info.date = date;
run_info.outfile = outfile;

run_info.script_name = mfilename;
clear imgArrays imgArraysNew imgArraysOld Instructions_image Instructions_image_fmri;
save(outfile);


% End of session screen

if test_comp == 1
    if sessionNum == 1
        
        Screen('TextSize',w, 40);
        CenterText(w,'Thank you!', white,0,0);
        Screen(w,'Flip');
    else
        
        Screen('TextSize',w, 40);
        CenterText(w,'Thank you!', white,0,0);
        Screen(w,'Flip');
    end
else
    if sessionNum == 1
        
        Screen('TextSize',w, 40);
        CenterText(w,'Thank you! Please read the instructions and proceed with PART 7.', white,0,0);
        Screen(w,'Flip');
    else
        
        Screen('TextSize',w, 40);
        CenterText(w,'Thank you!', white,0,0);
        Screen(w,'Flip');
    end
end


% Closing

WaitSecs(4);
toc
ShowCursor;
Screen('CloseAll');


% end % end function