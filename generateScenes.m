numCat = 5;
numScene = 1000;
maxNodes = 25;
maxNSize = maxNodes * 12;
maxCSize = maxNodes * 6;
maxESize = maxNodes * maxNodes * 2;

dstCntrs=[24 29];

for ii=1:2
    dsCntr = dstCntrs(ii);
    
    distScale = 50;
    if dsCntr > 19
        distScale = 1000;
    end
    
    transMtx = [-distScale + distScale*2*rand(numCat,3) zeros(numCat,3)];

    path = sprintf( 'locDatasets/syn%d/', dsCntr );
    
    InstLabels = [];
    Labels = [];
    SceneNodes = [];
    SceneEdges = [];
    SceneCenters = [];
    SceneDistances = [];

    for i=1:numCat
        fName = sprintf( '%s%dcenters.csv', path, i );
        Centers{i} = csvread(fName);
        fName = sprintf( '%s%dnodes.csv', path, i );
        Nodes{i} = csvread(fName);
        
    end
    
    for i=1:numScene
        
        nodes = [];
        centers = [];
        labels = [];
        edges = [];
        distances = []; 
        
        for j=1:numCat
            
            ind = randi(size(Nodes{j},1));
            numNodes = countNodes2(Nodes{j}(ind,:));
            nodes = [nodes Nodes{j}(ind,1:numNodes*12)];
            centers = [centers Centers{j}(ind,1:numNodes*6) + repmat(transMtx(j,:),1,numNodes)];
            labels = [labels j*ones(1,numNodes)];

        end
        
        currCent = reshape(centers,6,[])';
        for k=1:size(currCent,1)
            if nnz(currCent(k,:)) == 0
                break;
            end
            for l=1:size(currCent,1)

                if nnz(currCent(l,:)) == 0
                    break;
                end

                dist = (currCent(l,1:3)-currCent(k,1:3))*(currCent(l,1:3)-currCent(k,1:3))';
                angle = currCent(l,4:6)*currCent(k,4:6)';

                edges = [edges dist angle];
                distances = [distances dist];

            end    
        end
        
        if length(nodes) < maxNSize
            
            nodes = [nodes zeros(1, maxNSize-length(nodes))];
            edges = [edges zeros(1, maxESize-length(edges))];
            centers = [centers zeros(1, maxCSize-length(centers))];
            labels = [labels zeros(1, maxNodes-length(labels))];
            distances = [distances zeros(1, maxESize/2 - length(distances))];
            
        end
        
        InstLabels = [InstLabels; i*ones(size(currCent,1),1)];
        Labels = [Labels; labels];
        SceneNodes = [SceneNodes; nodes];
        SceneEdges = [SceneEdges; edges];
        SceneCenters = [SceneCenters; centers];
        SceneDistances = [SceneDistances; distances];
        
    end
    
    fName = sprintf( '%ssceneNodes.csv', path );
    csvwrite(fName, SceneNodes);
    fName = sprintf( '%ssceneEdges.csv', path );
    csvwrite(fName, SceneEdges);
    fName = sprintf( '%ssceneDistances.csv', path );
    csvwrite(fName, SceneDistances);
    fName = sprintf( '%ssceneCenters.csv', path );
    csvwrite(fName, SceneCenters);
    fName = sprintf( '%ssceneLabels.csv', path );
    csvwrite(fName, Labels);
    fName = sprintf( '%ssceneInstanceLabels.csv', path );
    csvwrite(fName, InstLabels);
    
end