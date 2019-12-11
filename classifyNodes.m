function score = classifyNodes( nodeData )

score = 0;

[ nodeCnt, refNodeCnt ] = size( nodeData);

bestCost = sum( min( nodeData, [], 2 ) );

allowedIndices = true( refNodeCnt, 1 );

unlabeledNodes = true( nodeCnt, 1 );

for i=1:nodeCnt
    
    
    [ val1, ind1 ] = min( nodeData( unlabeledNodes, allowedIndices), [], 2 );
    
    if isempty( val1 )
     
        [ val2, ind2 ] = min( min( nodeData( unlabeledNodes, : ), [], 2 ) );
        
        score = score + 2 * val2;
        
        inds = find( unlabeledNodes == 1 );
        
        nodeInd = inds( ind2 );
        
        unlabeledNodes( nodeInd ) = 0;        
        
    else
    
        [ val2, ind2 ] = min( val1 );
        
        inds = find( unlabeledNodes == 1 );
        
        nodeInd = inds( ind2 );        
        
        inds2 = find( allowedIndices == 1 );
        
        refInd = inds2( ind1( ind2 ) );
    
        score = score + val2;
        
        unlabeledNodes( nodeInd ) = 0;
        
        allowedIndices( refInd ) = 0;
        
    end
    
    
end

score = bestCost / score;