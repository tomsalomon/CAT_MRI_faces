function FA = FalseAlarm (Data)

Data=Data(Data(:,9)>=999000,:); % Use only NoGO trials
RT=Data(:,7);

FA=sum(RT<=1500)/length(RT); %