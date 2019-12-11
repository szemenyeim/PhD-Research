function A = createGraphModel( indices, Centers )

method = 0;

nodeCount = size( Centers, 1 );

% just one model
if method < 1
    
    % add all node vectors in to the model
    A = Centers;
        
% more models    
else
    
    graphCount = size( nodeCount, 1 );
    nodeInd = 1;
    
    hist = zeros( graphCount, nodeCount );
    
    % build node distribution histogram for all graphs
    for i=1:graphCount
        
        for j=1:nodeCount( i )
            
            hist( i, indices( nodeInd ) ) = hist( i, indices( nodeInd ) ) + 1;
            
            nodeInd = nodeInd + 1;
            
        end
        
    end
    
    % cluster them
    [ indices, histCent ] = clusterNodes( hist, 1, 5 );
    
    modelNum = size( histCent, 1 );
    
    % create graph model for each
    for i=1:modelNum
        
        currCent = 0;
        currInd = 1;
        
        for j=1:nodeCount
            
            for k=1:ceil( histCent( i, j ) )
                
                currCent( currInd + 1, : ) = Centers( j , : );
                currInd = currind + 1;
                
            end
            
        end
        
        A{ i } = currCent; 
        
    end
    
    
end