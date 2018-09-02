function IsLadderBelowThresh = ReachMinimalLadder (Data, thresh)
if nargin<=2
    thresh=200;
end
Data=Data(Data(:,9)<=1000,:); % Use only GO trials
ladders=[Data(:,12); Data(:,13)];
if(sum(ladders<=thresh)>=1)
    IsLadderBelowThresh=1;
else
    IsLadderBelowThresh=0;
end