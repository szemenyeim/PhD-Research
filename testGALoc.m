function [ result, optimFail ] = testGALoc( dataset, method )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

dataName = {'Synthetic10','Synthetic11','Synthetic12','Synthetic13','Synthetic14','Synthetic15','Synthetic16',...
'Synthetic17','Synthetic18','Synthetic19','Synthetic20','Synthetic21','Synthetic22','Synthetic23','Synthetic24',...
'Synthetic25','Synthetic26','Synthetic27','Synthetic28','Synthetic29','Synthetic1','Synthetic2','Image','Real Image'};
methodName = {'Vanilla','Mutation'};

fprintf([ 'Testing localization for ' dataName{dataset} ' data, and ' methodName{method+1} ' operator.\n' ]);

fprintf('Reading Data\n');

% globals
paths = {'locDatasets/syn10/','locDatasets/syn11/','locDatasets/syn12/','locDatasets/syn13/','locDatasets/syn14/',...
    'locDatasets/syn15/','locDatasets/syn16/','locDatasets/syn17/','locDatasets/syn18/','locDatasets/syn19/',...
    'locDatasets/syn20/','locDatasets/syn21/','locDatasets/syn22/','locDatasets/syn23/','locDatasets/syn24/',...
    'locDatasets/syn25/','locDatasets/syn26/','locDatasets/syn27/','locDatasets/syn28/','locDatasets/syn29/',...
    'locDatasets/syn/','locDatasets/syn2/','locDatasets/img/','locDatasets/realimg/'};

methodStr = 'mtx';
modelCnt = [5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 4];

global classNum
classNum = modelCnt(dataset);

global mutateRatio
global dragRatio
global distThreshold

global contRewards
contRewards = zeros( classNum );
% contRewards(1,2) = 20;
% contRewards(3,4) = 20;

global scalingFactor
scalingFactor = 2;

mutateRatio = 0.7;
dragRatio = 0.3;

% if method == 3
%     mutateRatio = 1;
%     dragRatio = 0;
% end

global Costs

% cost fun params
global rewards 
rewards = ones( classNum, 1 )*3;

% Read data
SceneData = csvread( [paths{dataset} methodStr 'scenePCAData.csv' ] );
PosData = csvread( [paths{dataset} 'sceneDistances.csv'] );

% Read Labels
SceneNodeLabels = csvread( [paths{dataset} 'sceneLabels.csv'] );
SceneInstanceLabels = csvread( [paths{dataset} 'sceneInstanceLabels.csv'] );

global models

global useSVM
useSVM = 1;

% Read Models       
models = load([paths{dataset} methodStr 'opticatModel.mat']);

nodeCnt = length(SceneInstanceLabels);

% Convert Scene instance labels to indices
SceneInstanceIndices = 1;
for i=2:nodeCnt
   
    if( SceneInstanceLabels(i) ~= SceneInstanceLabels(i-1) )
       
        SceneInstanceIndices = [SceneInstanceIndices i ];
        
    end
    
end

sceneCnt = length(SceneInstanceIndices);

SceneInstanceIndices = [SceneInstanceIndices nodeCnt+1 ];

labels = [];

global Distances

len = 0;
fval = 0;
goodCnt = 0;

optRes = zeros(sceneCnt,1);
trueRes = zeros(sceneCnt,1);

trueLabels = [];
for i=1:length(SceneInstanceIndices)-1
    trueLabels = [trueLabels SceneNodeLabels(i,1:SceneInstanceIndices(i+1)-SceneInstanceIndices(i))];
end

classLoss = loss( models.Mdl, SceneData, trueLabels );

tic
    
% Perform localization for every data point
for i=1:sceneCnt
    
    currNodeCnt = SceneInstanceIndices(i+1)-SceneInstanceIndices(i);
   
    Distances = reshape( PosData( i, 1:currNodeCnt*currNodeCnt ),[currNodeCnt,currNodeCnt]);
    distThreshold = max(max(Distances))/50;
    if method == 3
        distThreshold = 0;
    end
    [lab,fval] = localizeOperator( SceneData( SceneInstanceIndices(i):SceneInstanceIndices(i+1)-1 , : ), method );
    labels = [labels lab ];
    
    trueLab = SceneNodeLabels(i,1:SceneInstanceIndices(i+1)-SceneInstanceIndices(i));
    trueScene = zeros( currNodeCnt, classNum );
    optScene = zeros( currNodeCnt, classNum );
    for j=1:length(trueLab)
               
        optScene(j, lab(j) ) = 1;
        trueScene(j, trueLab(j) ) = 1;
        
    end
    
    optRes(i)=ga_fitness(optScene);
    trueRes(i) = ga_fitness(trueScene);
    
    if optRes(i) < trueRes(i)
        a = 1;
    end
    
    for k=1:len        
       fprintf('\b');
    end
    str = sprintf('Localizing scene %d of %d, opt: %f, true: %f',i,sceneCnt,fval, trueRes(i));
    fprintf(str);
    len = length(str);
    
end

time = toc;

% Evaluate localization
result = sum(labels==trueLabels) / nodeCnt;

costFunGood = sum(trueRes <= optRes ) / sceneCnt;
optimFail = sum(trueRes < optRes ) / sceneCnt;
fprintf('\n');
str = sprintf('Ratio of better cost functions: %f\n',costFunGood);
fprintf(str);
str = sprintf('Ratio of optimization fails: %f\n',optimFail);
fprintf(str);
str = sprintf('SVM classification loss: %f\n',classLoss);
fprintf(str);
str = sprintf('Classification accuracy: %f\n',result);
fprintf(str);
str = sprintf('Time spent: %f\n',time);
fprintf(str);

end

