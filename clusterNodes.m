function [ ind, C ] = clusterNodes( V, thresh )

method = 1;

testDim = 1;

% recursive
if method < 1

    [ ind, Clust ] = kmeans( V, 2 );
    
    if testDim == 1
        
        % project cluster to 1 dim
        vec = Clust( 1, : ) - Clust( 2 , : );
        norm = vec * vec';
        normalData = ( V * vec' ) / norm;    

        % perform compact test
        currC = computeCompactness( normalData, Clust, ind );
        prevC = computeCompactness( normalData, mean( normalData ), ones( length( normalData ), 1 ) );
        
    else
        
        % perform cluster test
        currC = computeCompactness( V, Clust, ind );
        prevC = computeCompactness( V, mean( V ), ones( size( V, 1 ), 1 ) );
        
    end
    
    if h == 1
        
        [ ind( ind( : ) == 1 ), C ] = clusterNodes( V( ind( : ) == 1, : ) );
        [ ind( ind( : ) == 2 ), C ] = clusterNodes( V( ind( : ) == 2, : ) );
        
    else
        
        if ~exist( 'C', 'var' )
            
            C = Clust;
        
        else
            
            C = [ C; Clust ];
            
        end
        
        ind( : ) = size( C, 1 ); 
        
    end
  
% iterative
else
    
    k = 1;
    
    ind = ones( 1, size( V, 1 ) );
    C = mean( V );
    
    comp( 1 ) = computeCompactness( V, C, ind );    
    
    while true
        
        [ ind_t, Clust_t, sumd ] = kmeans( V, k + 1 );
        %[ ind_t, Clust_t ] = kmedoids( V, k + 1 );
                
        % check compactness and break
        comp( k + 1 ) = sum(sumd);%computeCompactness( V, Clust_t, ind_t );
        
        if ( ( comp( k ) - comp( k + 1 ) ) / comp( 1 ) ) < thresh
            
            break;
            
        end
        
        ind = ind_t;
        C = Clust_t;
        
        k = k + 1;
        
    end
    
    
end
    
end