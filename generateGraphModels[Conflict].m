function generateGraphModels(database, methodNum, isTest, useSVM, modelsOnly)

if nargin < 5
    modelsOnly = 0;
end

dataName = {'Synthetic','Synthetic2','Image-Based','CAD-Based'};
modelName = {'Raw','Vectorial','Matrix'};
typeName = {'Train','Test'};
computeName = {'','computing models only'};

fprintf([ 'Generating graph models for ' dataName{database} ' data, with ' modelName{methodNum} ' embedding (' typeName{isTest+1} ') ' computeName{modelsOnly+1} '\n' ]);

fprintf('Reading Data\n');

categoryCnt = 5;
if database == 4
    categoryCnt = 10;
end

sceneStr = '';

if isTest == 1
    categoryCnt = 1;
    sceneStr = 'scene';
end

methodStr = ['noV';'vec';'mtx'];
    
vectorial = methodNum < 3;

Frac = 0.99;

paths = {'locDatasets/syn/','locDatasets/syn2/','locDatasets/img/','locDatasets/cad/'};

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
             
             [ currN, currE, D ] = sortNodes( Nv, Ev, k );
             
             [ fullN, fullE ] = createDummyNodes( currN, currE, 4, D );
             
             % These two functions have to be modified for additional
             % embedding methods
             
             DescMat = assembleGraphMatrix( fullN, fullE, 12, methodNum );             
             
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
    
        rng default;
        % Params: 
        % syn2 novec: ?, ?; vector: 50, 50; mtx: ?, ?
        % syn novec: , ; vector: ?, ?; mtx: ?, ?
        % img novec: , ; vector: ?, ?; mtx: ?, ?
        t = templateSVM('Standardize',1,'KernelFunction','gaussian','KernelScale',10,'BoxConstraint',10);
        %Mdl =
        %fitcecoc(PCAData,Y,'Learners',t,'FitPosterior',1,'OptimizeHyperparameters','auto',...
        %'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
        %'expected-improvement-plus'));
        Mdl = fitcecoc(PCAData,graphLabels,'Learners',t,'FitPosterior',1 );
        save([currPath methodStr(methodNum, :) 'catModel.model'], 'Mdl' );
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
end

    
    
    