function [Average, Maximum, Minimum, diff] = createOnsetList_old(mean_t,min_t,max_t,interval)
% Rotem Botvinik 4/12/14
% function [Average, Maximum, Minimum, diff] = createOnsetList(mean_t,min_t,max_t,interval)
% Create onsetlist for the probe.
% It should be checked that the mean of diff (variable Average) is close to
% the requested value
% Comments in the end are code lines ready to create this onsetlist and
% save it

onsetlist = zeros(1,136);
for i = 2:136
y = expsample(mean_t,min_t,max_t,interval);
onsetlist(i) = onsetlist(i-1)+y;
end
diff = onsetlist(2:end)-onsetlist(1:end-1);
Maximum = max(diff);
Minimum = min(diff);
Average = mean(diff);

% Creating and saving a new onsetlist with jitter mean 5, min 3, max 14,
% interval 1:

% [Average, Maximum, Minimum, diff] = createOnsetList(3,1,12,1);
% diff = diff+2;
% onsetlist = zeros(1,136);
% for i = 2:136
% onsetlist(i)=onsetlist(i-1)+diff(i-1);
% end
% newdiff = onsetlist(2:end)-onsetlist(1:end-1);
% mean(newdiff)
% save('probe_onset136_4','onsetlist');

end