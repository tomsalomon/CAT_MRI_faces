function stimBlocks = randomizeStaticAndAdd1Back(displayOrder, stimuliPerBlock, ftype, window, bgcolor, largeRect, objectsDir, facesDir, facesSubDirs)

rootDir = pwd();
facesBlocksCount = 0;
facesBlockRandIndices = randperm(8);

for idx = 1:length(displayOrder)
    switch displayOrder(idx)
        case 0
            stimBlocks(idx).type            = 'fixation';
            stimBlocks(idx).picturesPtr     = [];
            stimBlocks(idx).oneBackIndices  = [];
            stimBlocks(idx).filenames       = [];
            continue;
        case 1
            facesBlocksCount = facesBlocksCount + 1;
            stimBlocks(idx).type = 'faces';
            relevantDir = facesDir;
        case 2
            stimBlocks(idx).type = 'objects';
            relevantDir = objectsDir;
    end
    
    if strcmp(stimBlocks(idx).type, 'faces')
        folderNum = facesBlockRandIndices(facesBlocksCount);
        relevantDir = [ relevantDir '/Frame' num2str(folderNum) ];
    end
    
    % Get the picture filenames.
    cd(relevantDir);
    d = dir(['*.' ftype]);
    numitems = size(d, 1);
    pictures = cell(0);
    [pictures{1:numitems}] = deal(d.name);
        
    % Shuffle the pictures.
    pictures = pictures(randperm(length(pictures)));
    % Get 2 different random indices in the range of 1-14
    randIndices = sort(randperm(numitems,2));
    
    % Ensure they aren't consecutive.
    while abs(randIndices(1) - randIndices(2)) == 1
        randIndices = sort(randperm(numitems,2));
    end
    
    % Add them so we would have 1 back trials.
    pictures = pictures([ 1:randIndices(1) randIndices(1):randIndices(2) randIndices(2):end ]);
    % The oneBackIndices are the indices of trials where the subject will see the 
    % stimulus for the second time.
    stimBlocks(idx).oneBackIndices = [ (randIndices(1) + 1) (randIndices(2) + 2) ];
    stimBlocks(idx).filenames = pictures;
    
    % load the pictures to offscreen windows
    for picIdx = 1:length(pictures)
        [imgArray , ~] = imread(pictures{picIdx}, ftype); %read the pictures
        stimBlocks(idx).picturesPtr(picIdx) = Screen('MakeTexture', window, imgArray);
    end
    
    cd(rootDir);
end


% Older version of the loop. Here just for a reference.
%
% load the pictures to offscreen windows
%     for picIdx = 1:length(pictures)
%         [imgArray , cmap] = imread(pictures{picIdx}, ftype); %read the pictures
%         stimBlocks(idx).picturesPtr(picIdx) = Screen('OpenOffscreenWindow', window, bgcolor, largeRect, 32); %create the command
%         Screen(stimBlocks(idx).picturesPtr(picIdx), 'PutImage', imgArray); %open in offscreen window
%     end