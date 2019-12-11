function [N, E] = recoverOriginalGraph( descVec, transforMat, Means, nodeFeatureCnt, edgeFeatureCnt, nodeCnt, svCnt, squareFeatureCnt )

% Transform descriptor vector back
featVals = descVec * transforMat' + Means;
matFeats = reshape( featVals, floor( length( featVals ) / ( svCnt * 2 ) ), svCnt * 2 );

% Undo the SVD decomposition
realFeatVals = zeros( size( matFeats, 1 ) );
for i=1:svCnt
   
    realFeatVals = realFeatVals + matFeats( :, 2 * ( i - 1 ) + 1 ) * matFeats( :, 2 * i )';
    
end

realFeatVals( abs( realFeatVals )<0.05 ) = 0;

% Take logarithm
logFeatVals = real( log( realFeatVals ) );

% Assemble linear equation system
b = reshape( logFeatVals, size( logFeatVals, 1 ) ^ 2, 1 );
A = zeros( length( b ), nodeCnt * nodeFeatureCnt + nodeCnt * nodeCnt * edgeFeatureCnt );

matSize = size( logFeatVals, 1 );

edgeOffset = nodeCnt * nodeFeatureCnt;

ind = find( b ~= -Inf );

for i=1:length( b )
    
    col = mod( i - 1, matSize );
    row = floor( ( i - 1 ) / matSize );
    
    nodeInd1 = floor( row / squareFeatureCnt ); 
    nodeInd2 = floor( col / squareFeatureCnt ); 
    featInd1 = mod( row, squareFeatureCnt ) + 1;
    featInd2 = mod( col, squareFeatureCnt ) + 1;
    
    if featInd1 <= nodeFeatureCnt
    
        A( i, nodeInd1 * nodeFeatureCnt + featInd1 ) = A( i, nodeInd1 * nodeFeatureCnt + featInd1 ) + 1;
    
    else
        
        if( nodeInd1 ~= nodeInd2 )
        
            index = edgeOffset + ( featInd1 - nodeFeatureCnt - 1 ) * nodeInd1 * nodeCnt * edgeFeatureCnt + nodeInd2 * edgeFeatureCnt + 2;
            
            if ( index ~= 142 )
                
                A( i, index ) = A( i, index ) + 1;
                
            end
            
        end
        
    end
    
    if featInd2 <= nodeFeatureCnt
    
        A( i, nodeInd2 * nodeFeatureCnt + featInd2 ) = A( i, nodeInd2 * nodeFeatureCnt + featInd2 ) + 1;
        
    else
        
        if( nodeInd1 ~= nodeInd2 )
                        
            index = edgeOffset + ( featInd2 - nodeFeatureCnt - 1 ) * nodeInd1 * nodeCnt * edgeFeatureCnt + nodeInd2 * edgeFeatureCnt + 2;
            
            if ( index == 141 || index == 142 )
                
                A( i, index ) = A( i, index ) + 1;
                
            end
        
        end
        
    end
    
    if( nodeInd1 ~= nodeInd2 )
    
        A( i, edgeOffset + nodeInd1 * edgeFeatureCnt + 1 ) = A( i, edgeOffset + nodeInd1 * edgeFeatureCnt + 1 ) + 1;
        A( i, edgeOffset + nodeInd2 * edgeFeatureCnt + 1 ) = A( i, edgeOffset + nodeInd2 * edgeFeatureCnt + 1 ) + 1;

        A( i, edgeOffset + ( nodeInd1 * nodeCnt + nodeInd2 ) * edgeFeatureCnt + 1 ) = A( i, edgeOffset + ( nodeInd1 * nodeCnt + nodeInd2 ) * edgeFeatureCnt + 1 ) + 1;    

        A( i, 141 ) = 0;
    
    end
        
        
end

% Get indices of nonzero colums of a
pind = find( any( A( ind, : ), 1 ) );

AA = A( ind, pind );

% Solve it
B=pinv( AA );

solution = zeros( nodeCnt * nodeFeatureCnt + nodeCnt * nodeCnt * edgeFeatureCnt );

solution( pind ) =  exp( B*b( ind ) );

% Retrieve
for i=1:nodeCnt
   
    N( i, : ) = solution( ( i - 1 ) * nodeFeatureCnt + 1 : ( i ) * nodeFeatureCnt );
    
    for j=1:nodeCnt
       
        E( ( i - 1 )* nodeCnt + j, : ) = solution( edgeOffset + ( ( i - 1 ) * nodeCnt + j - 1 ) * edgeFeatureCnt + 1 : edgeOffset + ( ( i - 1 ) * nodeCnt + j ) * edgeFeatureCnt );
        E( ( i - 1 )* nodeCnt + j, 1 ) = 1 / ( E( ( i - 1 )* nodeCnt + j, 1 ) ) - 1;
        E( ( i - 1 )* nodeCnt + j, 2 ) = E( ( i - 1 )* nodeCnt + j, 2 );        
        
    end
    
    
end

E ( E == Inf ) = 0;
