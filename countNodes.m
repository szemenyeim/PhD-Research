function [ cnt, N, E ] = countNodes( Ni, Ei )

global NodeFeatureCount
nodeFCnt = NodeFeatureCount;

nodeECnt = NodeFeatureCount;

maxCnt = floor( size( Ni, 2 ) / nodeECnt );

cnt = maxCnt;

for i=1:maxCnt
    
    if nnz( Ni( ( i - 1 ) * nodeECnt + 1 : i * nodeECnt ) ) == 0
        
        cnt = ( i - 1 );
        
        break;
        
    end
    
    N( i, : ) = Ni( ( i - 1 ) * nodeECnt + 1 : ( i - 1 ) * nodeECnt + nodeFCnt );
    
end

for i=1:( cnt * cnt )
    
    E( i, : ) = Ei( ( i - 1 ) * 2 + 1 : i * 2 ); 
    
end