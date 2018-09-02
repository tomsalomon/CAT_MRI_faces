% function run_boost_Israel()

% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% =============== Created based on the previous boost codes ===============
% ================ by Rotem Botvinik November-December 2014 ===============
% =================== Modified by Tom Salomon, September 2015 =================
% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
% Runs the cue-approach task 

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ---------------- FUNCTIONS REQUIRED TO RUN PROPERLY: ----------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % %   --- Cue-approach codes: ---
% % %   'binary_ranking'
% % %   'binary_ranking_demo'
% % %   'sort_binary_ranking'
% % %   'trainingDemo_Israel'
% % %   'training_Israel' (if NO EYETRACKING)
% % %   'organizeProbe_Israel'
% % %   'probeDemo_Israel'
% % %   'probe_Israel'
% % %   'probeResolve_Israel'
% % %   'recognitionNewOld_Israel'
% % %   'recognitionGoNoGo_Israel'

% % %   --- Other codes: ---
% % %  'CenterText'

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % % ---------------- FOLDERS REQUIRED TO RUN PROPERLY: ------------------
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% % %   'Misc': a folder with the audio file.
% % %   'Onset_files': a folder with the onset files for the training and
% % %    for the probe.
% % %   'Output': the folder for the output files- results.
% % %   'stim': with the image files of all the stimuli for the cue-approach
% % %    task (old stimuli).
% % %   'stim/recognitionNew': with the image files of the new stimuli
% % %   (stimuli that are not included in the cue-approach tasks, only in the
% % %   recognitionNewOld task, as new stimuli).
clear all
tic

% =========================================================================
%% Get input args and check if input is ok
% =========================================================================

% %---dummy info for debugging purposes --------
% subjectID =  'BM_001';

% timestamp
c = clock;
hr = sprintf('%02d', c(4));
min = sprintf('%02d', c(5));
timestamp=[date,'_',hr,'h',min,'m'];

% essential for randomization
rng('shuffle');

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

sessionNum=1;

% set the computer and path
% --------------------------
test_comp=0; % 1 MRI, 0 if testooom
mainPath = pwd; % Change if you don't run from the experimnet folder - not recomended.
outputPath = [mainPath '/Output'];

% open a txt file for crashing logs
fid_crash = fopen([outputPath '/' subjectID '_crashingLogs' num2str(sessionNum) '_' timestamp '.txt'], 'a');

% =========================================================================
%% Personal Details
% =========================================================================
personal_details(subjectID, order, outputPath, sessionNum)

% =========================================================================
%% Part 1 - Binary Ranking (including demo)
% =========================================================================

Crashesd_binary_ranking_demo = 0;
keepTrying = 1;
while keepTrying < 10
    try
        binary_ranking_demo(subjectID,test_comp,mainPath);
        
        % Ask if subject wanted another demo
        % ----------------------------------
        demo_again = questdlg('Do you want to run the demo again?','Repeat Demo','Yes','No','No');
        if strcmp(demo_again,'Yes')
            binary_ranking_demo(subjectID,test_comp,mainPath);
        end
        keepTrying = 10;
    catch
        sca;
        Crashesd_binary_ranking_demo = Crashesd_binary_ranking_demo + 1;
        keepTrying = keepTrying + 1;
        disp('CODE HAD CRASHED - BINARY RANKING DEMO!');
    end
end
fprintf(fid_crash,'Binary ranking demo crashed:\t %d\n', Crashesd_binary_ranking_demo);

Crashesd_binary_ranking = 0;
keepTrying = 1;
while keepTrying < 10
    try
        binary_ranking(subjectID,test_comp,mainPath);
        keepTrying = 10;
    catch
        sca;
        Crashesd_binary_ranking = Crashesd_binary_ranking + 1;
        keepTrying = keepTrying + 1;
        disp('CODE HAD CRASHED - BINARY RANKING!');
    end
end
fprintf(fid_crash,'Binary ranking crashed:\t %d\n', Crashesd_binary_ranking);

% Sort stimuli according to the binary ranking
% -------------------------------------------------
sort_binary_ranking(subjectID,order,outputPath);

fclose(fid_crash);
sca;
WaitSecs(5);
% quit %quits matlab

% end % end function
