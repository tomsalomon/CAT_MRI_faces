function [summary] = validate_match(data_path)


if nargin <1
    data_path = './pre_processed_data/';
end

txt_files = dir([data_path,'*.txt']);
edf_files = dir([data_path,'*.edf']);
asc_files = dir([data_path,'*.asc']);

txt_filenames = {txt_files.name}';
edf_filenames = {edf_files.name}';
asc_filenames = {asc_files.name}';

txt_filenames_no_end = cellfun(@(x) x(1:end-4),txt_filenames,'UniformOutput',false);
edf_filenames_no_end = cellfun(@(x) x(1:end-4),edf_filenames,'UniformOutput',false);
asc_filenames_no_end = cellfun(@(x) x(1:end-4),asc_filenames,'UniformOutput',false);

match_txt2asc = (cellfun(@(x) sum(contains(asc_filenames_no_end,x)),txt_filenames_no_end,'UniformOutput',false));
match_txt2edf = (cellfun(@(x) sum(contains(edf_filenames_no_end,x)),txt_filenames_no_end,'UniformOutput',false));

summary=cell2table([txt_filenames,match_txt2edf,match_txt2asc],'VariableName',{'txt_file','have_edf','have_asc'});
txt_files_n = length(summary.have_edf);
edf_files_n = sum(summary.have_edf);
asc_files_n = sum(summary.have_asc);
% corruptedfiles = 1-sum(summary.have_asc)/sum(summary.have_edf);
% have_edf_proportion = sum(summary.have_edf)/length(summary.have_edf);
% have_asc_proportion = sum(summary.have_asc)/length(summary.have_edf);

fprintf([...
    '\nEye-Tracker Data Preprocessing Summary\n'....
    '=========================================\n'...
    'txt files: %i\n'...
    'edf files: %i (prop. = %.2f)\n'...
    'asc files: %i.(prop. = %.2f, currepted edf file prop. = %.2f)\n'],...
    txt_files_n, edf_files_n, edf_files_n/txt_files_n, asc_files_n, asc_files_n/txt_files_n, (1 - asc_files_n/edf_files_n));

