

code_path='/export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/scripts/make_activations_table/activations_table_code/';
data_path='/export/home/DATA/schonberglab/effort_mixed_gambles/analysis_2018/derivatives/models/';
models={'010'};
tasks={'002', '003'};
copes1={'1'};
copes2={'1'};
contrasts={'1','2'};


% read anatomical labels 'id_num' and 'name'
HOA = readtable([code_path '/roifolder/HarvardOxford-combo-labels_COPY.txt']);
HOA.Properties.VariableNames= {'id_num','name'};

%%
Contrast={};
Cluster=[];
Region={};
Voxels=[];
Clustersize=[];
X=[];
Y=[];
Z=[];
Peakzstat=[];

counter=1;
for model=1:length(models)
    for task=1:length(tasks)
        for cope1=1:length(copes1)
            for cope2=1:length(copes2)
                for contrast=1:length(contrasts)
                    
                    N_clusters=length(dir([code_path 'output/model' models{model} '_task' tasks{task}  '_level1cope' copes1{cope1} '_level2cope' copes2{cope2} '_contrast' contrasts{contrast} '_*.txt' ]));
                    
                    for cluster=1:N_clusters
                        
                        cluster_T = readtable([data_path 'model' models{model} '/group/group_task' tasks{task}  '_cope' copes1{cope1} '.gfeat/cope' copes2{cope2} '.feat/cluster_zstat' contrasts{contrast} '_std.txt']);
                        %
                        %  try to get the clusterBYroi_T, if there were no clusters for the contrast, there will be no file
                        try clusterBYroi_T = readtable([code_path 'output/model' models{model} '_task' tasks{task}  '_level1cope' copes1{cope1} '_level2cope' copes2{cope2} '_contrast' contrasts{contrast} '_cluster' num2str(cluster) '.txt' ]);
                            relevantROIs=find(clusterBYroi_T{:,'numvox'}>9);
                            
                            for region=1:length(relevantROIs)
                                Contrast{counter,1}=(['model' models{model} '_task' tasks{task}  '_level1cope' copes1{cope1} '_level2cope' copes2{cope2} '_contrast' contrasts{contrast}]);
                                Cluster(counter,1)=cluster;
                                Region{counter,1}=HOA{relevantROIs(region),'name'};
                                Voxels(counter,1)=clusterBYroi_T{relevantROIs(region),'numvox'};
                                Clustersize(counter,1)=cluster_T{cluster_T{:,'ClusterIndex'}==cluster,'Voxels'};
                                X(counter,1)=cluster_T{cluster_T{:,'ClusterIndex'}==cluster,'Z_MAXX_mm_'};
                                Y(counter,1)=cluster_T{cluster_T{:,'ClusterIndex'}==cluster,'Z_MAXY_mm_'};
                                Z(counter,1)=cluster_T{cluster_T{:,'ClusterIndex'}==cluster,'Z_MAXZ_mm_'};
                                Peakzstat(counter,1)=cluster_T{cluster_T{:,'ClusterIndex'}==cluster,'Z_MAX'};
                                
                                counter=counter+1;
                                
                            end
                        catch
                        end
                    end
                end
            end
        end
    end
end


activations_table=table(Contrast,Cluster,Region,Voxels,Clustersize,X,Y,Z,Peakzstat)   ;
writetable(activations_table,[code_path 'results/activations_table_model' models{:} '_' date '.csv']);
