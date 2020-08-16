function [opt,plainLoss,kloss] = generateGraphModels(database, methodNum, isTest, useSVM, modelsOnly)

if nargin < 5
    modelsOnly = 0;
end

global NodeFeatureCount

NodeFeatureCount = 64

opt = 0;
plainLoss = 0;
kloss = 0;

dataName = {'Synthetic10','Synthetic11','Synthetic12','Synthetic13','Synthetic14','Synthetic15','Synthetic16',...
 'Synthetic17','Synthetic18','Synthetic19','Synthetic20','Synthetic21','Synthetic22','Synthetic23','Synthetic24',...
 'Synthetic25','Synthetic26','Synthetic27','Synthetic28','Synthetic29'};
%dataName = {'Image2','Image3','Image4','Image5','Image6'};
modelName = {'Raw','Vectorial','Matrix'};
typeName = {'Train','Test'};
computeName = {'','computing models only'};

fprintf([ 'Generating graph models for ' dataName{database} ' data, with ' modelName{methodNum} ' embedding (' typeName{isTest+1} ') ' computeName{modelsOnly+1} '\n' ]);

fprintf('Reading Data\n');

catNums = [5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5];
%catNums = [2 3 5 16 6];

categoryCnt = catNums(database);

sceneStr = '';

if isTest == 1
    categoryCnt = 1;
    sceneStr = 'scene';
end

dummyCnt = [4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4];
%dummyCnt = [4 4 4 4 4 4];

methodStr = ['noV';'vec';'mtx'];
    
vectorial = methodNum < 3;

Frac = 0.99;

paths = {'locDatasets/syn10/','locDatasets/syn11/','locDatasets/syn12/','locDatasets/syn13/','locDatasets/syn14/',...
    'locDatasets/syn15/','locDatasets/syn16/','locDatasets/syn17/','locDatasets/syn18/','locDatasets/syn19/',...
    'locDatasets/syn20/','locDatasets/syn21/','locDatasets/syn22/','locDatasets/syn23/','locDatasets/syn24/',...
    'locDatasets/syn25/','locDatasets/syn26/','locDatasets/syn27/','locDatasets/syn28/','locDatasets/syn29/'};
% paths = {'locDatasets/img2/','locDatasets/img3/','locDatasets/img4/','locDatasets/img5/','locDatasets/img6/'};

currPath = paths{database};
    
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

if modelsOnly == 0
 
 if isTest == 0
    [ ScaledNodes, ScaledEdges, means, var ] = scaleFeatures( tempNodes, tempEdges, [], [] );
 else
     means = csvread( [currPath 'NodeMeans.csv'] );
     var = csvread( [currPath 'NodeVar.csv'] );
     [ ScaledNodes, ScaledEdges ] = scaleFeatures( tempNodes, tempEdges, means, var );
 end

 dummy = -means./var;
 
startInd = 1;
startEInd = 1;

Dist = [];

currIdx = 1;
totalCnt = sum(graphCnt);

fprintf('Vectorizing data\n');

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
             
             [ fullN, fullE ] = createDummyNodes( currN, currE, dummyCnt(database), dummy );
             
             % These two functions have to be modified for additional
             % embedding methods
             
             DescMat = assembleGraphMatrix( fullN, fullE, methodNum );             
             
             svNum = 2;
             
             if vectorial
                svNum = 1;
             end
             
             if nodeInd == 1
                
                 v = zeros( sum(sum(nodeCnt)), length(vectorizeGraph( DescMat, svNum )) );
                 
             end
             
             v( nodeInd, : ) = vectorizeGraph( DescMat, svNum ) ;
                          
             nodeInd = nodeInd + 1;
             
         end
         
     end
    
     catIndices( i + 1 ) = nodeInd;
     
 end
 
fprintf('\n');

 graphLabels = zeros( 1, size( v, 1 ) );

 for i=1:length( catIndices ) - 1
    
     graphLabels( catIndices( i ):end ) = graphLabels( catIndices( i ):end ) + 1;
    
 end

 instanceLabels = instanceLabels( 2:end );
 csvwrite( [currPath  methodStr(methodNum, :) sceneStr 'NodeData.csv' ], v );
 csvwrite( [currPath sceneStr 'InstanceLabels.csv'], instanceLabels );
 csvwrite( [currPath sceneStr 'Distances.csv'], Dist );


 %v = csvread( [currPath methodStr(methodNum, :) sceneStr 'NodeData.csv'] );

 if isTest == 0
    
    fprintf('Getting LDA\n');
    csvwrite( [currPath 'NodeMeans.csv'], means );
    csvwrite( [currPath 'NodeVar.csv'], var );
    csvwrite( [currPath 'catIndices.csv'], catIndices );
    csvwrite( [currPath 'NodeLabels.csv'], graphLabels );
    graphLabels = csvread( [currPath sceneStr 'InstanceLabels.csv'] );
    
    pcaMethod = 6;
    if methodNum == 1
        pcaMethod = 6;
    end

    [ PCAData, TransformMat, Means ] = getPCA( v, Frac, catIndices, graphLabels, pcaMethod, 0 );
 
    csvwrite( [currPath methodStr(methodNum, :) 'PCAData.csv'], PCAData );
 
    csvwrite( [currPath methodStr(methodNum, :) 'PCATransform.csv'], TransformMat );
 
    csvwrite( [currPath methodStr(methodNum, :) 'PCAMeans.csv'], Means );
 
 else
     
    fprintf('Performing LDA\n');
    TransformMat = csvread( [currPath methodStr(methodNum, :) 'PCATransform.csv'] );
    
    PCAData = v * TransformMat;
 
    csvwrite( [currPath methodStr(methodNum, :) 'scenePCAData.csv'], PCAData );
    
 end
 
end

if isTest == 0
    
    if modelsOnly == 1
        
        PCAData = csvread([currPath methodStr(methodNum, :) 'PCAData.csv']);
        catIndices = csvread( [currPath 'catIndices.csv'] );
        graphLabels = csvread( [currPath 'NodeLabels.csv'] );
    end
    
    fprintf('Computing models\n');
    
    subCCnt = [3 2 4 5 3; 3*[1 1 1 1 1]];
    
    if useSVM
    
        graphLabels = csvread( [currPath 'NodeLabels.csv'] );
        PCAData = csvread([currPath methodStr(methodNum, :) 'PCAData.csv']);
        
        rng default;
        % Params: 
        % syn2 50
        % syn 10
        % img 30
        t = templateSVM('Standardize',0,'KernelFunction','linear','KernelScale',10,'BoxConstraint',10,...
            'CacheSize','maximal','IterationLimit',1e4);
        hypers = hyperparameters('fitcecoc',PCAData,graphLabels,'svm');
        hypers(2,1).Range = [0.5 1000];
        hypers(3,1).Range = [0.5 1000];
        Mdl = fitcecoc(PCAData,graphLabels,'Learners',t,'Coding','onevsall','OptimizeHyperparameters',hypers,...
        'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
        'expected-improvement-plus','MaxObjectiveEvaluations',50,'Holdout',0.2));   
        vec = Mdl.HyperparameterOptimizationResults.XAtMinObjective;
        t = templateSVM('Standardize',0,'KernelFunction','linear','KernelScale',vec.KernelScale,'BoxConstraint',...
            vec.BoxConstraint,'CacheSize','maximal','IterationLimit',1e4);
        opt = Mdl.HyperparameterOptimizationResults.MinObjective;
        Mdl = fitcecoc(PCAData,graphLabels,'Learners',t,'Coding',Mdl.CodingName );
        plainLoss = loss( Mdl, PCAData, graphLabels ); 
        str = sprintf( 'Training Finished... Loss: %0.5f\n',plainLoss);
        fprintf(str);
        CVMdl = crossval( Mdl );
        kloss = kfoldLoss( CVMdl ); 
        str = sprintf( 'Cross-validation Finished... Loss: %0.5f\n',kloss);
        fprintf(str);
        save( [currPath methodStr(methodNum, :) 'opticatModel.mat'], 'Mdl' );
        %saveCompactModel(Mdl,[currPath methodStr(methodNum, :) 'catModel.model'] );
        
    else
        for i=1:categoryCnt

            if database > 2
                [ classes, ClusterCenters ] = clusterNodes( PCAData( catIndices( i ) : catIndices( i + 1 ) - 1, : ), 0.01 );
            else
                [ classes, ClusterCenters ] = kmeans( PCAData( catIndices( i ) : catIndices( i + 1 ) - 1, : ), subCCnt(database,i) );
            end

            M = createGraphModel( classes, ClusterCenters );

            fName = sprintf( [currPath methodStr(methodNum, :) 'catModel%d.csv'], i );

            csvwrite( fName, M );

        end
    end
else 
    
    
    
end

    
    
    