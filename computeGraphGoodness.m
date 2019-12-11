function goodness = computeGraphGoodness( graphNodes, graphEdges, Model, nodeGoodnesses )

% sum node goodnesses
goodness = nodeGoodnesses' * nodeGoodnesses;

% punish large edge distances
alpha = 1;
goodness = goodness - alpha * ( graphEdges' * graphEdges );

% punish missing nodes from model
nodeCnt = size( Model, 1 );
currNodeCnt = size( graphNodes, 1 );

beta = 1;
punishment = ones( nodeCnt, 1 );

for i=1:currNodeCnt
    
    punishment( graphNodes( i, 2 ) ) = 0;
    
end

goodness = goodness - beta * ( punishment' * punishment );