
categoryCnt = 5;

max = 0.999;
best = 0;
currBest = 0;

currPath = 'locDatasets/syn2/';
methodStr = 'mtx';

PCAData = csvread([currPath methodStr 'PCAData.csv']);
catIndices = csvread( [currPath 'catIndices.csv'] );    

% Read data
SceneData = csvread( [currPath methodStr 'scenePCAData.csv' ] );

% Read Labels
SceneNodeLabels = csvread( [currPath 'sceneLabels.csv'] );
SceneInstanceLabels = csvread( [currPath 'sceneInstanceLabels.csv'] );

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
    
fprintf('Computing models\n');

trueLabels = [];
for i=1:length(SceneInstanceIndices)-1
    trueLabels = [trueLabels SceneNodeLabels(i,1:SceneInstanceIndices(i+1)-SceneInstanceIndices(i))];
end

global models

a=5;

while true
    
    
    subCCnt = a*[1 1 1 1 1];
    %a=a+1;

    for i=1:categoryCnt

        [ classes, ClusterCenters ] = kmeans( PCAData( catIndices( i ) : catIndices( i + 1 ) - 1, : ), subCCnt(i) );

        models{i} = createGraphModel( classes, ClusterCenters );

    end    
    
    for i=1:categoryCnt    
       
        c = getNodeCosts(SceneData( trueLabels == i, : )); 
    
        res(i) = sum(min(c')' == c(:,i))/size(c,1);
        
    end  

    resres = mean(res);
    str = sprintf('Result: %d Best: %d\n',resres,best);
    fprintf(str);
    
    if( resres > best )
        best = resres;
        bestModels = models;
    end
    
    if( resres > max )
        break;
    end

end


for i=1:categoryCnt
    
    fName = sprintf( [currPath methodStr 'catModel%d.csv'], i );
 
    csvwrite( fName, bestModels{i} );
    
end