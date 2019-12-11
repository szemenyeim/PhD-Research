function [ Nodes, Edges ] = gaussianScale( NodesIn, EdgesIn )

nodeCnt = size( NodesIn, 2 ) / 20;
edgeCnt = size( EdgesIn, 2 ) / 2;

Nodes = NodesIn;
Edges = EdgesIn;

for i=1:14
    
    featureVec = NodesIn( NodesIn( :, i ) ~= 0 , i );
    
    for j=2:nodeCnt
        
        featureVec =[ featureVec; NodesIn( NodesIn( :, ( j - 1 ) * 20 + i ) ~= 0 , ( j - 1 ) * 20 + i ) ];
        
    end
    
    Means( i ) = mean( featureVec );
    Vars( i ) = var( featureVec );
    
end

for i=1:2
    
    featureVec = EdgesIn( EdgesIn( :, i ) ~= 0 , i );
    
    for j=2:edgeCnt
        
        featureVec =[ featureVec; EdgesIn( EdgesIn( :, ( j - 1 ) * 2 + i ) ~= 0 , ( j - 1 ) * 2 + i ) ];
        
    end
    
    MeansE( i ) = mean( featureVec );
    VarsE( i ) = var( featureVec );
    
end

i = 1:14;
j = 1:2;

Nodes( NodesIn( :, mod( :, 14 ) == i ) ~= 0, mod( :, 14 ) == i ) = ( Nodes( NodesIn( :, mod( :, 14 ) == i ) ~= 0, mod( :, 14 ) == i ) - Means( i ) ) / Vars( i );
Edges( EdgesIn( :, mod( :, 2 ) == j ) ~= 0, mod( :, 2 ) == j ) = ( Edges( EdgesIn( :, mod( :, 2 ) == j ) ~= 0, mod( :, 2 ) == j ) - MeansE( j ) ) / VarsE( j );