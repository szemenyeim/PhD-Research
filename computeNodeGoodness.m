function NodeGoodness = computeNodeGoodness( nodeVec, Model )

nodeCnt = size( nodeVec, 1 );
modelNodeCnt = size( Model, 1 );

for i=1:nodeCnt
    for j=1:modelNodeCnt
    
    % compute similarity of the node and the model
    NodeGoodness( i, j ) = ( nodeVec( i, : ) - Model( j, : )' )' * ( nodeVec( i, : ) - Model( j, : )' );    
   
    
    end
end