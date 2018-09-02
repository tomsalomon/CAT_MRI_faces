input_path = './../Output_all_files/'; % here is your data
Files = dir([input_path,'*resopnse*']);
for i = 1:numel(Files)
    old_name = Files(i).name;

    new_name = strrep(old_name,'resopnse','Response');
    movefile([input_path,old_name],[input_path,new_name])
end