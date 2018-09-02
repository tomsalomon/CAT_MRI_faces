function CountMisses = MinimalLadder (Data, ~)

Data=Data(Data(:,9)<=1000,:); % Use only GO trials
RT=Data(:,7);

CountMisses=sum(RT>1500)/length(RT); %