function stimBlocks = randomizeDynamicAndAdd1Back(displayOrder, stimuliPerBlock, window, bgcolor, largeRect, objectsDir, facesDir)

rootDir = pwd();

for idx = 1:length(displayOrder)
    switch displayOrder(idx)
        case 0
            stimBlocks(idx).type = 'fixation';
            stimBlocks(idx).picturesPtr     = [];
            stimBlocks(idx).oneBackIndices  = [];
            stimBlocks(idx).filenames       = [];
            continue;
        case 1
            stimBlocks(idx).type = 'faces';
            ftype = 'avi';
            relevantDir = [ pwd() filesep() facesDir ];
        case 2
            stimBlocks(idx).type = 'objects';
            ftype = 'avi';
            relevantDir = [ pwd() filesep() objectsDir ];
    end
    
    % Get the video filenames.
    cd(relevantDir);
    d = dir(['*.' ftype]);
    numitems = size(d, 1);
    videos = cell(0);
    [videos{1:numitems}] = deal(d.name);
    
    % Shuffle the videos.
    videos = videos(randperm(length(videos)));
    % Get 2 different random indices in the range of 1-14
    randIndices = sort(randperm(numitems,2));
    
    % Ensure they aren't consecutive.
    while abs(randIndices(1) - randIndices(2)) == 1
        randIndices = sort(randperm(numitems,2));
    end
    
    % Add them so we would have 1 back trials.
    videos = videos([ 1:randIndices(1) randIndices(1):randIndices(2) randIndices(2):end ]);
    % The oneBackIndices are the indices of trials where the subject will see the 
    % stimulus for the second time.
    stimBlocks(idx).oneBackIndices = [ (randIndices(1) + 1) (randIndices(2) + 2) ];
    stimBlocks(idx).filenames = videos;
    
    fullFilenames = cell(1, length(videos));
    
    for fileItr = 1:length(videos)
        fullFilename = [ relevantDir filesep() videos{fileItr} ];
        fullFilenames{fileItr} = fullFilename;
    end
    
    stimBlocks(idx).fullFilenames = fullFilenames;
    
    cd(rootDir);
end