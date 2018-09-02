function result = displayStaticStimBlockMRI(nofixation, window, centerPosn, centerPosn1, itemPtr, fixation, oneBackIndices, stimNames, trialDuration, stimDisplayTime, outerLoopTimeOffset, totalBlockTime)

isFixation      = isempty(itemPtr);
elapsedTime     = 0;
timeOffset      = outerLoopTimeOffset; % Used to balance the trial runtime.
totalBlockTime  = trialDuration*length(itemPtr);

result = cell(16,4);

%% Fixation trials.
if isFixation
    totalBlockTime = trialDuration*16;
    fixationTimer = GetSecs();
    
    Screen('DrawTexture', window, fixation);
    Screen(window,'Flip');
    
    for idx = 1:16
        result(idx, :) = { 'Fixation', '', '' , '' };
    end
    
    timeToWait = totalBlockTime -(GetSecs() - fixationTimer) - 0.005 + timeOffset;
    
    pause(timeToWait);
    
    Screen('DrawTexture', window, nofixation);
    Screen(window,'Flip');
    
    return;
end

wholeBlockTimer = GetSecs();

for itr = 1:length(itemPtr)
    RTdifftemp = GetSecs();
    
    Screen('DrawTexture', window, itemPtr(itr), [], centerPosn); % display the image
    Screen(window,'Flip');
    
    waitForKeypress = true;
    RT = 'none';
    keyPressed = 'none';
    isCorrect = true;
    
    while waitForKeypress
        [avail, ~, keyCode] = KbCheck; %% check for keypress
        
        if avail ~= 0
            waitForKeypress = false;
            RT = GetSecs() - RTdifftemp;
        end
        
        elapsedTime = GetSecs() - RTdifftemp;
        
        % Hide the stimulus after 1 second.
        if elapsedTime >= stimDisplayTime
            Screen('DrawTexture', window, nofixation);
            Screen(window,'Flip');
            break;
        end
    end
    
    if avail == 1
        keyFinder = find(keyCode);
        keyFinder = keyFinder(1);
        
        if keyFinder == 71
            keyPressed = 'G';
        elseif keyFinder == 82
            keyPressed = 'R';
        elseif keyFinder == 66
            keyPressed = 'B';
        elseif keyFinder == 89
            keyPressed = 'Y';
        elseif keyFinder == 27
            sca;
            error('Experiment terminated by pressing Esc');
        end
        
        if any(find(oneBackIndices == itr))
            isCorrect = true;
        else
            isCorrect = false;
        end
    end
    
    % If this is a one back stimulus, and the subject failed to press a key.
    if avail == 0 && any(find(oneBackIndices == itr))
        isCorrect = false;
    end
    
    result(itr, :) = { stimNames(itr), RT, keyPressed, isCorrect };
    
    Screen('Close', itemPtr(itr));
    
    elapsedTime = GetSecs() - RTdifftemp;
    
    if elapsedTime < stimDisplayTime
        pause(stimDisplayTime - elapsedTime);
        
        Screen('DrawTexture', window, nofixation);
        Screen(window,'Flip');
    end
    
    elapsedTime = GetSecs() - RTdifftemp;
    
    % If we are displaying the last stimuli, and the whole block took a little
    % bit too long, we shorten the ISI for the last stimuli.
    if itr == length(itemPtr)
        % The time to wait is the time that the whole block should be displayed
        % minus the time that the block took so far, minus 5 millisecons (to be safe).
        timeToWait = totalBlockTime - (GetSecs() - wholeBlockTimer) - 0.005;
        pause(timeToWait);
    elseif elapsedTime < trialDuration + timeOffset
        % In case the subject pressed a key before 'trialDuration' has passed.
        pause(trialDuration - (GetSecs() - RTdifftemp));
    end
    
end