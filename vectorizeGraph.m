function v = vectorizeGraph( A, svCount, length )

if svCount == 1
    v = A;
    return;
end

method = 0;

[ U, S, V ] = svd( A );

svCount = svCount - 1;

num = size( V, 1 );

if nargin < 3

    assert( svCount <= num );

    if method < 1

        for i=1:svCount
        
            v( num * ( i - 1 ) + 1 : num * i ) = [ sqrt(S(i,i))*U(:,i) ];

        end

    else

        for i=1:svCount
        
            v( i ) = S( i, i );

        end

        for i=1:svCount
        
            v( svCount + num * ( i - 1 ) + 1 : svCount + num * i ) = V ( :, i );

        end
    end

else
    
    assert( length <= num );

    for i=1:length
        
        v( i ) = S( i, i );

    end

end
end