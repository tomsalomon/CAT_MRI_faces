function result = displayDynamicStimBlockMRI(nofixation, window, centerPosn, centerPosn1, fixation, oneBackIndices, stimNames, type, fullStimNames, trialDuration, outerLoopTimeOffset, totalBlockTime, stimDisplayDuration,allBlocksTimer,BlockNum)

KbName('UnifyKeyNames');
KbQueueCreate;
DisableKeysForKbCheck(KbName('t')); % So trigger is no longer detected

isFixation      = isempty(stimNames);
elapsedTime     = 0;
timeOffset      = outerLoopTimeOffset; % Used to balance the trial runtime.
totalBlockTime  = trialDuration*length(stimNames);


result = cell(16,6);

%% Fixation trials.
if isFixation
    totalBlockTime = trialDuration*16;
    fixationTimer = GetSecs();
    
    Screen('CopyWindow', fixation, window, [], centerPosn);
    Screen(window,'Flip');
    
    for videoIdx = 1:16
        result(videoIdx, :) = { (videoIdx+(BlockNum-1)*16),'','Fixation', '', '' , '' };
    end
    
    timeToWait = totalBlockTime -(GetSecs() - fixationTimer) - 0.005 + timeOffset;
    pause(timeToWait);
    
    Screen('CopyWindow', nofixation, window, [], centerPosn);
    Screen(window,'Flip');
    
    return;
end

%% Play movies
wholeBlockTimer = GetSecs();
KbQueueFlush;
KbQueueStart;

for videoIdx = 1:length(fullStimNames)
     isOneBack=any(find(oneBackIndices == videoIdx));
     
    fullFilename        = fullStimNames{videoIdx};
    receivedKeyPress    = false;
    RT          = 'none';
    keyPressed  = 'none';
%     isCorrect   = true;
    StimTime=GetSecs-allBlocksTimer;
    
    [movie, ~, fps] = Screen('OpenMovie', window, fullFilename);
    Screen('PlayMovie', movie, 1);
    
    RTdifftemp = GetSecs();
    
    % Movie playback variables. Do not delete any of them.
    movietexture    = 0;
    reactiontime    = -1;
    lastpts         = 0;
    onsettime       = -1;
    rejecttrial     = 0;
    timeOfEvent     = 0;
    keyFinder = 0;
    
    % Documentation in: DetectionRTInVideoDemo.m (psychtoolbox demos folder).
    while(movietexture>=0 && reactiontime==-1)
        [movietexture, pts] = Screen('GetMovieImage', window, movie, 0);
        if (movietexture>0)
            Screen('DrawTexture', window, movietexture, [], centerPosn);
            vbl=Screen('Flip', window);
            
            if (onsettime==-1 && pts >= timeOfEvent)
                onsettime = vbl;
                if (pts - lastpts > 1.5*(1/fps))
                    rejecttrial=1; % Ignore this !! but don't delete it.
                end;
            end;
            
            % check for keypress
            if ~receivedKeyPress && (GetSecs - RTdifftemp < stimDisplayDuration)
                %{ 
                % If subject did not respond and this is not a oneBack
                if isOneBack
                    isCorrect = false;
                else
                    isCorrect = true;
                end
                %}
                    
                % check for response
                [keyIsDown, firstPress] = KbQueueCheck;
                if keyIsDown && ~receivedKeyPress
                    keyPressed=KbName(firstPress);
                    receivedKeyPress    = true;
                    RT = GetSecs() - RTdifftemp;
                    %                     reactiontime=1;
                    if ischar(keyPressed)==0 % if 2 keys are hit at once, they become a cell, not a char. we need keyPressed to be a char, so this converts it and takes the first key pressed
                        keyPressed=char(keyPressed);
                        keyPressed=keyPressed(1);
                        KbQueueFlush;
                        KbQueueStart;
                    end
                    if ~ismember(keyPressed,['r','g','b','y'])
                        receivedKeyPress = false;
                        keyPressed = 'none';
                        RT = 'none';
%                     elseif isOneBack % If subject respond and this is a oneBack - correct
%                     isCorrect = true;
                    end
                    disp(['keyPressed: ' keyPressed]);
                end
                
            end
            
            lastpts=pts;
            
            Screen('Close', movietexture);
            movietexture=0;
            
            % Another test to ensure the movie won't play too long.
            if GetSecs() - RTdifftemp >= stimDisplayDuration
                break;
            end
        end;
    end
    
    % Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie:
    Screen('CloseMovie', movie);
    
    Screen('CopyWindow', nofixation, window, [], centerPosn);
    Screen(window,'Flip');
    
    % Cheack if subject's respons was correct
    if isOneBack == receivedKeyPress
        isCorrect = true;
    else
        isCorrect = false;
    end
    
    %     if receivedKeyPress
    %         %         if keyFinder == 71
    %         %             keyPressed = 'G';
    %         %         elseif keyFinder == 82
    %         %             keyPressed = 'R';
    %         %         elseif keyFinder == 66
    %         %             keyPressed = 'B';
    %         %         elseif keyFinder == 89
    %         %             keyPressed = 'Y';
    %         %         elseif keyFinder == 27
    %         %             sca;
    %         %             error('Experiment terminated by pressing Esc');
    %         %         else
    %         % %             disp('else');
    %         %         end
    %
    %         if any(find(oneBackIndices == videoIdx))
    %             isCorrect = true;
    %         else
    %             isCorrect = false;
    %         end
    %     end
    
    % If this is a one back stimulus, and the subject failed to press a key.
    %     if ~receivedKeyPress && any(find(oneBackIndices == videoIdx))
    %         isCorrect = false;
    %     end
    %
    result(videoIdx, :) = { (videoIdx+(BlockNum-1)*16),StimTime,stimNames(videoIdx), RT, keyPressed, isCorrect };
    
    elapsedTime = GetSecs() - RTdifftemp;
    
    if (videoIdx == 1) && (elapsedTime < trialDuration + timeOffset)
        timeToWait = (trialDuration + timeOffset) - elapsedTime - 0.005;
        pause(timeToWait);
    elseif elapsedTime < trialDuration
        % i.e., in the 2 video, we could wait for: (2*1) - 1.92 = 0.08 seconds.
        timeToWait = (videoIdx*trialDuration) - (GetSecs() - wholeBlockTimer);
        pause(timeToWait);
    end
end
DisableKeysForKbCheck([]); % Restore 't' button functionality
KbQueueFlush;
