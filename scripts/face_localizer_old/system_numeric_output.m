function [first_num_output,all_num_outputs] = system_numeric_output(str_input)
% run a system command and return the output as numeric variables. strings
% returna as NaN. First output is to use only the first number output. The
% Second output can be used to get a vector with all numbers returned by
% the system function.

% run system
[~,str_output]=system(str_input);
% split the string output you got from the system function
str_output_tmp = strsplit(str_output,{' ','/t',','});
% convert string to numeric
all_num_outputs = str2double(str_output_tmp);
% return the first numeric output
first_num_output = all_num_outputs(1);
end
