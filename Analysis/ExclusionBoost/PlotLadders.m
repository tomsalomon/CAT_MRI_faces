function PlotLadders (Data)

% ladder in all trials
Ladders1_with_duplicate=Data(:,12);
Ladders2_with_duplicate=Data(:,13);

% Where the ladders had changed
Ladders1_Change_location=Data(:,6)==11;
Ladders2_Change_location=Data(:,6)==22;

%     % remove trials where ladder didn't change (NoGo trials)
%     % add 750 for the very first trial
%     Ladders1=[750;Ladders1_with_duplicate(Ladders1_Change_location)];
%     Ladders2=[750;Ladders2_with_duplicate(Ladders2_Change_location)];
Ladders1=[Ladders1_with_duplicate(Ladders1_Change_location)];
Ladders2=[Ladders2_with_duplicate(Ladders2_Change_location)];

% plot Ladders for single subjects
figure (Data(1))
plot(Ladders1,'b-') % HV Ladder in blue
hold on
plot(Ladders2,'r-') % LV Ladder in red
ylim([0,950])

% % calculate time subject needed to respond
% time_2_response=Data(:,7)-Data(:,9);
% % replace trials with no response with the mean time to respond
% time_2_response(time_2_response>1000|time_2_response<-1000)=mean(time_2_response(time_2_response<=1000&time_2_response>=-1000));
% % divide results to HV and LV
% time_2_response1=time_2_response(Ladders1_Change_location);
% time_2_response2=time_2_response(Ladders2_Change_location);
% 
% % plot Ladders for single subjects
% plot(time_2_response1,'.-','color',[0.4,0.4,1]) % HV RT in blue
% hold on
% plot(time_2_response2,'.-','color',[1,0.4,0.4]) % LV RT in red
% hold on
% plot(1:length(time_2_response2),zeros(1,length(time_2_response2)),'--','color','black')

