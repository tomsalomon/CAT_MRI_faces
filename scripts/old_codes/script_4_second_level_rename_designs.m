
clear;
curr_dir=pwd;
cd './../models/model001/designs/';
for sub=1:50
    for task=1
        
        % e.g. design_task001_fixed_effects.fsf
        fin = fopen(['design_task00',num2str(task),'_fixed_effects.fsf']);
        
        if sub<10
            sub_name=['sub00',num2str(sub)];
        else
            sub_name=['sub0',num2str(sub)];
        end
        
        task_name=['task00',num2str(task)];
        
        
        fout = fopen(['design_',sub_name,'_',task_name,'_model001.fsf'],'w');
        
        while ~feof(fin)
            s = fgetl(fin);
            s = strrep(s, 'sub001', sub_name);
            fprintf(fout,'%s\n',s);
            %             disp(s)
        end
        
        fin=fclose(fin);
        fout=fclose(fout);
        
    end
end

cd(curr_dir);

% clear;
% curr_dir=pwd;
% cd './../models/model001/designs/';
% 
% for sub=2:9
% 
%         fin = fopen('designlevel2.fsf');
%         
%         if sub<10
%             sub_name=['sub00',num2str(sub)];
%         else
%             sub_name=['sub0',num2str(sub)];
%         end
%         
%         fout = fopen(['design_',sub_name,'_model001.fsf'],'w');
% 
%         while ~feof(fin)
%             s = fgetl(fin);
%             s = strrep(s, 'sub001', sub_name);
%             fprintf(fout,'%s\n',s);
% %             disp(s)
%         end
%         
%         fin=fclose(fin);
%         fout=fclose(fout);
% 
% end
% 
% cd(curr_dir);
