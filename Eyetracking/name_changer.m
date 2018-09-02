
function [output_name] = name_changer(input)
% +~+~+~+~+~+~+~+~+~+~+~+~+ Written By Tom Salomon +~+~+~+~+~+~+~+~+~+~+~+~
% +~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+ July 2018 +~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+
% +~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+
%
% This function is used to convert MRI faces files to unified file names
% for behavioral txt file and eyetracking asc files.
% The function can take as input either a single file name as string, a
% cell array with multiple file names or a struct outputed by dir function.
%
% output_name will be a nX1 cell array with the new names



if iscell(input)  % Deal with cell array inputs
    input_names = input;
elseif isstruct(input) % Deal with dir struct inputs
    input_names={input.name};
else % Deal with single char/str inputs
    input_names = {input};
end

% preallocation
output_name = cell(numel(input_names),1);
task_names = {'Response','Training','Probe'};

for i = 1:numel(input_names)
    name_tmp = input_names{i};
    splitFileName = strsplit(name_tmp,'_');
    task_id = find(...
        [contains(name_tmp,task_names(1),'IgnoreCase',true),...
        contains(name_tmp,task_names(2),'IgnoreCase',true),...
        contains(name_tmp,task_names(3),'IgnoreCase',true)]);
    
    is_asc =  contains (name_tmp,'.asc') || contains (name_tmp,'.edf');
    is_txt =  contains (name_tmp,'.txt');
    ending = name_tmp(end-2:end);
    
    switch task_id
        
        case 1 % Response to stim
            is_after = contains(name_tmp,'after','IgnoreCase',true);
            session = nan;
            if is_asc
                session = str2double(splitFileName{7});
            elseif is_txt
                session = str2double(splitFileName{5}(end));
            end
            scan_ind = session + is_after;
            
        case 2 % Training
            if is_asc
                scan_ind = floor((str2double(splitFileName{9})+1)/2);
            elseif is_txt
                scan_ind =floor((str2double(splitFileName{6})+1)/2);
            end
            
        case 3 % Probe
            block = nan;
            run = nan;
            if is_asc
                block = str2double(splitFileName{7});
                run = str2double(splitFileName{9}(end));
            elseif is_txt
                block = str2double(splitFileName{6});
                run = str2double(splitFileName{7}(end));
            end
            scan_ind = (block-1)*2 + run;
    end
    
    
    if ~isnan(scan_ind)
        output_name{i} = sprintf('%s_%s_%s_%s_%i.%s',...
            splitFileName{1},splitFileName{2},splitFileName{3},task_names{task_id},scan_ind,ending);
    else
        output_name{i}=' ';
        warning('on')
        warning('No Scan ID to %s',name_tmp)
    end
end

if numel(input_names)==1
   output_name=cell2mat(output_name);
end
