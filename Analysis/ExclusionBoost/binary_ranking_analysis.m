function BR_Outliers=binary_ranking_analysis(outputPath,prefix)
%clear all;

% Define analysis and output paths
analysis_path=pwd;
if nargin<2
    prefix='';
end

if nargin<1
    outputPath='~/Desktop/Outputs/';
end
% These are all the subjects' ranking results files
ranking_files=dir([outputPath prefix '*ItemRankingRes*']);

rankings=zeros(length(ranking_files),60); % Rankings of the 60 stimuli, each column identify a particular stimulus
stdevs=zeros(length(ranking_files),1); % Standard deviations of the final ranking table of each sunject. Small STD
% may indicate low preferences for different stimuli (i.e. the subject did not like certain stimuli more then others)
SubID=cell(length(ranking_files),1);
ReactionTime=zeros(length(ranking_files),1);
TransitiveChoices=cell(length(ranking_files),1);
ColleyViolations=cell(length(ranking_files),1);
NumberOfTransitiveChoices=zeros(length(ranking_files),1);
NumberOfColleyViolations=zeros(length(ranking_files),1);
ViolationSize=cell(length(ranking_files),1);
SumOfViolationSize=zeros(length(ranking_files),1);

% Go through each sunbject's file and extract the data
for i=1:length(ranking_files)
    fid=fopen([outputPath,ranking_files(i).name]);
    data=textscan(fid,'%s %s %f %f %f %f %f %f','Headerlines',1);
    SubID{i}=data{1}(1);
    
    % contains a table with the data sorted by the stimuli's names: 1)SubjectID	2)StimName	3)StimNum	4)Rank	5)Wins	6)Loses  7)Total
    rankings(i,:)=data{5}'; % Stimuli's rankings, sorted alphabetically (e.g - first number is the '001.TIFF' ranking; second number is the '002.TIFF' ranking, etc.)
    fid=fclose(fid);
    stdevs(i)=std(data{5});
end



StimRank=data{5};
StimNames=data{2};
% convert StimNames from string to double
for i=1:length(StimNames)
    StimNames{i}=StimNames{i}(1:3);
end
StimNames=str2double(StimNames);

choices_files=dir([outputPath prefix '*_binary_ranking_*.txt']);
no_choices=zeros(length(choices_files),1);
for i=1:length(choices_files)
    fid=fopen([outputPath,choices_files(i).name]);
    data=textscan(fid,'%s %f %f %s %s %f %f %s %f %f %f','Headerlines',1);
    fid=fclose(fid);
    
    no_choices(i)=sum(cell2mat(data{8})=='x');
    RT=data{1,10};
    RT(RT==999000)=[];
    ReactionTime(i)=mean(RT);
    
    SubjectChoice=cell2mat(data{8});
    SubjectChoseLeft=SubjectChoice=='u';
    SubjectChoseRight=SubjectChoice=='i';
    ImageLeft=data{4};
    ImageRight=data{5};
    
    for j=1:length(ImageLeft)
        ImageLeft{j}=ImageLeft{j}(1:3);
        ImageRight{j}=ImageRight{j}(1:3);
    end
    
    ImageLeft=str2double(ImageLeft);
    ImageRight=str2double(ImageRight);
    
    RankLeft=zeros(length(ImageLeft),1);
    RankRight=zeros(length(ImageLeft),1);
    
    for stimNum=1:length(StimNames)
        RankLeft(ImageLeft==StimNames(stimNum))=StimRank(stimNum);
        RankRight(ImageRight==StimNames(stimNum))=StimRank(stimNum);
    end
    
    TransitiveChoices{i}=((RankLeft>RankRight)&SubjectChoseLeft)|((RankLeft<RankRight)&SubjectChoseRight);
    ColleyViolations{i}=((RankLeft<RankRight)&SubjectChoseLeft)|((RankLeft>RankRight)&SubjectChoseRight);
    NumberOfTransitiveChoices(i)=sum(TransitiveChoices{i});
    NumberOfColleyViolations(i)=sum(ColleyViolations{i});
    ViolationSize{i}=ColleyViolations{i}.*abs(RankLeft-RankRight);
    SumOfViolationSize(i)=sum(ViolationSize{i});
end

% Print results: standard deviation of Colley Rankings
outliers=stdevs>(mean(stdevs)+3*std(stdevs))|stdevs<(mean(stdevs)-3*std(stdevs));
fprintf('\nA total of %d outliers were found using Colley rankings standard deviation:\n',sum(outliers));
fprintf('3 std confidence interval is: %.4f - %.4f\n',(mean(stdevs)-3*std(stdevs)),(mean(stdevs)+3*std(stdevs)));

findOutliers=find(outliers);
for i=1:length(findOutliers)
fprintf('%s had a Colley rankings standard deviation of %.4f\n',cell2mat(SubID{findOutliers(i)}),stdevs(findOutliers(i)));
end


% Print results: standard deviation of Colley Rankings
outliers=NumberOfColleyViolations>(mean(NumberOfColleyViolations)+3*std(NumberOfColleyViolations))|NumberOfColleyViolations<(mean(NumberOfColleyViolations)-3*std(NumberOfColleyViolations));
fprintf('\nA total of %d outliers were found using Colley violations count:\n',sum(outliers));
fprintf('3 std confidence interval is: %.4f - %.4f\n',(mean(NumberOfColleyViolations)-3*std(NumberOfColleyViolations)),(mean(NumberOfColleyViolations)+3*std(NumberOfColleyViolations)));

findOutliers=find(outliers);
for i=1:length(findOutliers)
fprintf('%s had a sum of %d Colley violations\n',cell2mat(SubID{findOutliers(i)}),NumberOfColleyViolations(findOutliers(i)));
end


% Print results: standard deviation of Colley Rankings
outliers=SumOfViolationSize>(mean(SumOfViolationSize)+3*std(SumOfViolationSize))|SumOfViolationSize<(mean(SumOfViolationSize)-3*std(SumOfViolationSize));
fprintf('\nA total of %d outliers were found using sum of violations sizes:\n',sum(outliers));
fprintf('3 std confidence interval is: %.4f - %.4f\n',(mean(SumOfViolationSize)-3*std(SumOfViolationSize)),(mean(SumOfViolationSize)+3*std(SumOfViolationSize)));

findOutliers=find(outliers);
for i=1:length(findOutliers)
fprintf('%s had a sum of %.4f violations sizes\n',cell2mat(SubID{findOutliers(i)}),SumOfViolationSize(findOutliers(i)));
end

OutliersTmp=cell2mat([(SubID{findOutliers})]');
if ~isempty(OutliersTmp)
    BR_Outliers=str2num(OutliersTmp(:,end-2:end));
else
    BR_Outliers=[];
end