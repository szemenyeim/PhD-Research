function goodness = computeSetupGodness( Objects, ObjGoodnesses, Nodes, Edges, Requirements )

nodeCnt = size( Nodes, 1 );

% sum object goodnesses
goodness = ObjGoodnesses' * ObjGoodnesses;

% Requirements contains:
    % The number of object category instances required
    % The pcnt of the scene to setup
    % The fitgoodness of neighboring objects

% punish changes in node categories
    % depending on the categories and distances

punishment = 0;
    
for i=1:nodeCnt
    
    for j=i+1:nodeCnt
        
        n1 = nonZero( Nodes( i, : ) );
        n2 = nonZero( Nodes( j, : ) );
        
        l1 = size( n1 );
        l2 = size( n2 );
        
        for k=1:l1
            
           for l=1:l2
               
               punishment = punishment + Requirements.neighbor( n1( k ), n2( l ) ) * Edges( i, j);
               
           end
            
        end
        
    end    
    
end    

goodness = goodness - alpha * punishment;

% punish number of objects
categoryIdx = 1:5;

objCnt( categoryIdx ) = sum( Objects{ : }.modelInd == categoryIdx );

goodness = goodness - beta * ( objCnt - Requirements.catCnt )' * ( objCnt - Requirements.catCnt );

% punish pcnt. of nodes assigned to objects
indVec = 1:nodeCnt;

nodeUses( indVec ) =  nnz( Nodes( indVec, : ) );
usedNodePcnt = nnz ( nodeUses ) / nodeCnt;

goodness = goodness - gamma * ( usedNodePcnt - Requirements.nodePcnt ) ^ 2;


% punish objects using the same nodes
overUsedCnt = sum( nodeUses > 1 );

goodness = goodness - delta * overUsedCnt;