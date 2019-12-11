function [ opt,plainLoss,kloss ] = testRWK( database, skipOrder, isTest )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

opt = 0;
plainLoss = 0;
kloss = 0;

dataName = {'Synthetic10','Synthetic11','Synthetic12','Synthetic13','Synthetic14','Synthetic15','Synthetic16',...
'Synthetic17','Synthetic18','Synthetic19','Synthetic20','Synthetic21','Synthetic22','Synthetic23','Synthetic24',...
'Synthetic25','Synthetic26','Synthetic27','Synthetic28','Synthetic29'};

fprintf([ 'Testing RWK for ' dataName{database} ' data\n' ]);

fprintf('Reading Data\n');

catNums = [5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 ];

categoryCnt = catNums(database);

paths = {'locDatasets/syn10/','locDatasets/syn11/','locDatasets/syn12/','locDatasets/syn13/','locDatasets/syn14/',...
    'locDatasets/syn15/','locDatasets/syn16/','locDatasets/syn17/','locDatasets/syn18/','locDatasets/syn19/',...
    'locDatasets/syn20/','locDatasets/syn21/','locDatasets/syn22/','locDatasets/syn23/','locDatasets/syn24/',...
    'locDatasets/syn25/','locDatasets/syn26/','locDatasets/syn27/','locDatasets/syn28/','locDatasets/syn29/',};

currPath = paths{database};

sceneStr = '';
if isTest == 1
    categoryCnt = 1;
    sceneStr = 'scene';
end
if skipOrder == 0
    
    [ Nodes, Edges, graphCnt ] = readNEData( currPath, categoryCnt, isTest );
    
    startIndex = 0;
    
    instanceLabels = 0;
    
    nodeInd = 1;
    
    catIndices = 1;
    
    tempNodes = [];
    tempEdges = [];
    
    fprintf('Scale data\n');
    
    for i=1:categoryCnt
        
        startIndex = [ startIndex startIndex( i ) + graphCnt( i ) ];
        
        for j=1:graphCnt( i )
            
            [ nodeCnt( i, j ), NodeVec, EdgeVec ] = countNodes( Nodes( startIndex( i ) + j, : ), Edges( startIndex( i ) + j, : ) );
            
            instanceLabels = [ instanceLabels; ( instanceLabels( end ) + 1 ) * ones( nodeCnt( i, j ), 1 ) ];
            
            tempNodes = [tempNodes; NodeVec];
            tempEdges = [tempEdges; EdgeVec];
            
        end
        
    end
    
    means = [];
    var = [];
    if isTest == 1        
        means = load( [paths{database} 'means.mat'] );
        means = means.means;
        var = load( [paths{database} 'std.mat'] );
        var = var.var;
    end
    
    [ScaledNodes, ScaledEdges, means, var ] = scaleFeatures( tempNodes, tempEdges, means, var );
    
    
    startInd = 1;
    startEInd = 1;
    
    Dist = [];
    
    currIdx = 1;
    totalCnt = sum(graphCnt);
    nodeCount = sum(sum(nodeCnt));
    
    N = cell(nodeCount, 1 );
    E = cell(nodeCount, 1 );
    
    fprintf('Prepare data\n');
    
    len = 0;
    
    for i=1:categoryCnt
        
        for j=1:graphCnt( i )
            
            for k=1:len
                fprintf('\b');
            end
            str = sprintf('Vectorizing graph %d of %d',currIdx,totalCnt);
            fprintf(str);
            len = length(str);
            currIdx = currIdx+1;
            
            Nv = ScaledNodes( startInd:startInd+nodeCnt(i,j)-1, : );
            Ev = ScaledEdges( startEInd:startEInd+nodeCnt(i,j)*nodeCnt(i,j)-1, : );
            
            Dist = padconcatenation( Dist, Ev(:,1)', 1 );
            
            startInd = startInd+nodeCnt(i,j);
            startEInd = startEInd+nodeCnt(i,j)*nodeCnt(i,j);
            
            for k=1:nodeCnt( i, j )
                
                [ currN, currE ] = sortNodes( Nv, Ev, k );
                
                N{nodeInd} = currN;
                E{nodeInd} = currE;
                
                nodeInd = nodeInd + 1;
            end
            
        end
        
    end
    
    save( [paths{database} sceneStr 'rwkN.mat'], 'N' );
    save( [paths{database} sceneStr 'rwkE.mat'], 'E' );
    if isTest == 0        
        save( [paths{database} 'means.mat'], 'means' );
        save( [paths{database} 'std.mat'], 'var' );
    end
    
else
    
    temp = load( [paths{database} sceneStr 'rwkN.mat'] );
    N = temp.N;
    temp = load( [paths{database} sceneStr 'rwkE.mat'] );
    E = temp.E;
    nodeCount=size(N,1);
    
end
if isTest == 0 && false

    graphLabels = csvread( [currPath 'NodeLabels.csv'] );
    
    dummyData = 1:nodeCount;

    rng default

    indices = randperm(nodeCount);
    trainNum = 6000;
    indices = indices(1:trainNum);

    newN = N(indices);
    newE = E(indices);
    newX = dummyData(1:trainNum);
    newY = graphLabels(indices);

    global best
    global iterCnt
    best = 1;
    iterCnt = 1;

    NKernVal = optimizableVariable('Nv',[0.001,0.5],'Type','real');
    EKernVal = optimizableVariable('Ev',[0.001,2],'Type','real');
    weightSlope = optimizableVariable('wS',[0.01,2],'Type','real');
    distanceWeight = optimizableVariable('dW',[0.01,10],'Type','real');
    BoxConstraint = optimizableVariable('BC',[0.1,1000],'Type','real');

    fun = @(x)getSVM(newN,newE,newX,newY,x.Nv,x.Ev,x.wS,x.dW,x.BC);
    results = bayesopt(fun,[NKernVal,EKernVal,weightSlope,distanceWeight,BoxConstraint],'Verbose',0,...
        'AcquisitionFunctionName','expected-improvement-plus','MaxObjectiveEvaluations',10);
        %,'UseParallel',false);

    opt = results.MinObjective;
    params = results.XAtMinEstimatedObjective;
    
    str = sprintf( 'Bayes Finished... Loss: %0.5f\n',opt);
    fprintf(str);
    
    evalKernel(newN,newE,newN,newE,params.Nv,params.Ev,params.wS,params.dW,(1:trainNum)', 1);

    t = templateSVM('Standardize',0,'KernelFunction','dummyKernel','BoxConstraint',...
        params.BC,'CacheSize','maximal','IterationLimit',1e5);
    Mdl = fitcecoc(newX',newY,'Learners',t,'Coding','onevsall' );

    plainLoss = loss( Mdl, newX', newY );
    str = sprintf( 'Training Finished... Loss: %0.5f\n',plainLoss);
    fprintf(str);

    CVMdl = crossval( Mdl );
    kloss = kfoldLoss( CVMdl );
    str = sprintf( 'Cross-validation Finished... Loss: %0.5f\n',kloss);
    fprintf(str);

    save( [currPath sceneStr 'opticatRWKModel.mat'], 'Mdl' );
    save( [currPath sceneStr 'RWKparams.mat'], 'params' );
    save( [currPath sceneStr 'trainIndices.mat'], 'indices' );

end

