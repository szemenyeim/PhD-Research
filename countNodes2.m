function cnt = countNodes2( Ni )

nodeECnt = 12;

maxCnt = floor( size( Ni, 2 ) / nodeECnt );

cnt = maxCnt;

for i=1:maxCnt
    
    if nnz( Ni( ( i - 1 ) * nodeECnt + 1 : i * nodeECnt ) ) == 0
        
        cnt = ( i - 1 );
        
        break;
        
    end
end