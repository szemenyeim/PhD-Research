function [ outputRes, outputCost, trainErr, valErr ] = optimizeContext( dataset, vecType, useSVMin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

rng default;

dataName = {'Synthetic','Synthetic2','Image-Based','Real Image','Image Context','Real Context'};
modelName = {'Raw','Vectorial','Matrix'};

fprintf([ 'Optimizing context for ' dataName{dataset} ' data, with ' modelName{vecType} ' embedding.\n' ]);

% globals
paths = {'locDatasets/syn/','locDatasets/syn2/','locDatasets/img/','locDatasets/realimg/','locDatasets/contimg/','locDatasets/contreal/'};

methodStr = ['noV';'vec';'mtx'];
modelCnt = [5 5 5 4 5 4];
factors = [4, 2, 2];

global classNum
classNum = modelCnt(dataset);

global scalingFactor
scalingFactor = factors(vecType);

global mutateRatio
global dragRatio
global distThreshold

mutateRatio = 0.7;
dragRatio = 0.3;

global Costs
global Distances

% cost fun params
global contRewards
contRewards = zeros( classNum );
global rewards
rewards = ones( classNum, 1 )*3;

%[outputRes(1), outputCost(1)] = testLoc(dataset,vecType,1,useSVMin);

% Read data
Scenes = csvread( [paths{dataset} methodStr(vecType, :) 'scenePCAData.csv' ] );
PosData = csvread( [paths{dataset} 'sceneDistances.csv'] );

% Read Labels
SceneLabels = csvread( [paths{dataset} 'sceneLabels.csv'] );
SceneInstanceLabels = csvread( [paths{dataset} 'sceneInstanceLabels.csv'] );

global models

global useSVM
useSVM = useSVMin;

% Read Models
if useSVM == 1
    models = load([paths{dataset} methodStr(vecType, :) 'opticatModel.mat']);
else
    for i=1:modelCnt(dataset)
        models{i} = csvread(sprintf( [paths{dataset} methodStr(vecType, :) 'catModel%d.csv'], i ));
    end
    
end

nodeCnt = length(SceneInstanceLabels);

% Convert Scene instance labels to indices
SceneInstanceIndices = 1;
for i=2:nodeCnt
    
    if( SceneInstanceLabels(i) ~= SceneInstanceLabels(i-1) )
        
        SceneInstanceIndices = [SceneInstanceIndices i ];
        
    end
    
end

SceneInstanceIndices = [SceneInstanceIndices nodeCnt+1 ];
sceneCnt = size( SceneLabels, 1 );

mutateCnt = 100;

N = 4;

len = 0;

doneAlready = false;

if exist([paths{dataset} methodStr(vecType,:) 'bests.mat'], 'file') == 2
    Labels = load( [paths{dataset} methodStr(vecType,:) 'bests.mat'] );
    Labels = Labels.Labels;
    doneAlready = true;
end

% For every scene
for i=1:sceneCnt
    
    % Setup variables
    Costs = getNodeCosts( Scenes( SceneInstanceIndices(i) : SceneInstanceIndices(i+1)-1, : ) );
    CostVals{i} = Costs;
    currNodeCnt = SceneInstanceIndices(i+1)-SceneInstanceIndices(i);
    Distances = reshape( PosData( i, 1:currNodeCnt*currNodeCnt ),[currNodeCnt,currNodeCnt]);
    DistanceVals{i} = Distances;
    if ~doneAlready
        trueLab = SceneLabels(i,1:SceneInstanceIndices(i+1)-SceneInstanceIndices(i));
        trueScene = zeros( currNodeCnt, classNum );
        for j=1:length(trueLab)
            
            trueScene(j, trueLab(j) ) = 1;
            
        end
        orig = reshape( trueScene, 1, classNum*currNodeCnt );
        distThreshold = max(max(DistanceVals{i}))/50;
        ga_fitness(orig);
        
        Labels{i} = initPopulation( orig, mutateCnt);
        
    end
    
    for k=1:len
        fprintf('\b');
    end
    str = sprintf('Preparing scene %d of %d',i,sceneCnt);
    fprintf(str);
    len = length(str);
    
    
end

if ~doneAlready
    
    save( [paths{dataset} methodStr(vecType,:) 'bests.mat'], 'Labels' );
    
end

fprintf('\n');

% Permute Scenes
ind = randperm( sceneCnt );

% Split train and valid
trainCnt = floor(sceneCnt*0.8);
for i=1:trainCnt
    
    TrainCost{i} = CostVals{ ind(i) };
    TrainDist{i} = DistanceVals{ ind(i) };
    TrainLabel{i} = Labels{ ind(i) };
    
end

valCnt = sceneCnt - trainCnt;
for i=1:valCnt
    
    ValCost{i} = CostVals{ ind(trainCnt + i) };
    ValDist{i} = DistanceVals{ ind(trainCnt + i) };
    ValLabel{i} = Labels{ ind(trainCnt + i) };
    
end

CostVals = [];
DistanceVals = [];
Labels = [];

lRate = 0.1;
lRateDec = 0.00002;
wDecay = 0.001;

epochCnt = 30;
trainAcc = zeros( epochCnt + 1, 1 );
valAcc = zeros( epochCnt + 1, 1 );
TrainTemp = cell(trainCnt,1);
ValTemp = cell(valCnt,1);

% For every epoch
for i=0:epochCnt
    
    % Permute traindata
    currInd = randperm( trainCnt );
    
    str = sprintf('Epoch #%d, Learning Rate:%d\n',i,lRate);
    fprintf(str);
    trainBin = 0;
    
    len = 0;
    
    % for every data
    for j=1:trainCnt
        
        % Get cost functions
        Costs = TrainCost{ currInd( j ) };
        Distances = TrainDist{ currInd( j ) };
        distThreshold = max(max(Distances))/50;
        if i == 0
            population = TrainLabel{ currInd( j ) };
            examples = getBestCandidates( population(2:end,:), N, 1, population(1,:) );
            TrainTemp{ currInd( j ) } = examples;
        else
            examples = TrainTemp{ currInd( j ) };
        end
        result = zeros( 1, N+1 );
        
        % Get derivative relative to the context mtx
        grad = zeros( classNum );
        for k=1:N+1
            [ result(k), grads ] = ga_fitness( examples( k, : ) );
            if k == 1
                grads = - N*grads;
            end
            grad = grad + grads;
        end
        
        if( min(result) == result(1) )
            trainBin = trainBin+1;
        end
        
        if i > 0
            % Adjust context mtx
            contRewards = contRewards - lRate * grad/norm(reshape(grad,classNum*classNum,1));
            
            % Adjust learning rate
            lRate = lRate*(1-lRateDec);
        end
        
        for k=1:len
            fprintf('\b');
        end
        str = sprintf('Training scene %d of %d',j,trainCnt);
        fprintf(str);
        len = length(str);
        
    end
    
    % Normalize context mtx
    %contRewards = contRewards/norm(reshape(contRewards,classNum*classNum,1));
    
    %     if i > 0
    %     end
    
    trainAcc(i+1) = trainBin/trainCnt*100;
    
    str = sprintf('\nTrain accuracy: %0.2f\n',trainAcc(i+1));
    fprintf(str);
    
    valBin = 0;
    
    len = 0;
    
    % for every data
    for j=1:valCnt
        
        % evaluate cost functions
        Costs = ValCost{ j };
        Distances = ValDist{ j };
        if i == 0
            population = ValLabel{ j };
            examples = getBestCandidates( population(2:end,:), N, 1, population(1,:) );
            ValTemp{ j } = examples;
        else
            examples = ValTemp{ j };
        end
        result = zeros( 1, N+1 );
        for k=1:N+1
            result(k) = ga_fitness( examples( k, : ) );
        end
        
        if( min(result) == result(1) )
            valBin = valBin+1;
        end
        
        
        for k=1:len
            fprintf('\b');
        end
        str = sprintf('Validating scene %d of %d',j,valCnt);
        fprintf(str);
        len = length(str);
        
    end
    
    valAcc(i+1) = valBin/valCnt*100;
    
    str = sprintf('\nValidation accuracy: %0.2f\n',valAcc(i+1));
    fprintf(str);
    
end

csvwrite( [paths{dataset} methodStr(vecType,:) 'contRewads.csv' ], contRewards );

figure
plot( 1:(epochCnt+1), 100-trainAcc, 1:(epochCnt+1), 100-valAcc );
title('SGD Results')
xlabel('Epoch #')
ylabel('Error')
legend('Training Error','Validation Error')

trainErr = [100-trainAcc(1) 100-trainAcc(end)];
valErr = [100-valAcc(1) 100-valAcc(end)];

[outputRes(2), outputCost(2)] = testLoc(dataset,vecType,1,useSVMin);

end

