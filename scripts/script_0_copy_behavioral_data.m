
% Copy Behavioral data to the MRI folder
clear;
   behave_data_original_dir=('~/Dropbox/Experiment_Israel/Codes/MRI_faces/Output/');
   behave_data_out_dir='./behavioral_data/';
   
   behave_data_files=dir([behave_data_original_dir,'*.txt']);
   for i=1:length(behave_data_files)
       old_name=behave_data_files(i).name;
       new_name=['sub0',old_name(12:end)];
       copyfile([behave_data_original_dir,old_name],[behave_data_out_dir,new_name]);
   end
   
   % Delete demo file
   delete([behave_data_out_dir,'*demo*']);
   % Delete crashing logs files file
   delete([behave_data_out_dir,'*crashing*']);
 