function [ N, E, cnt ] = readNEData( path, catNum, method )

if method < 1

    for i=1:catNum

        fullPN = sprintf( '%s%dnodes.csv', path, i );
        fullPE = sprintf( '%s%dedges.csv', path, i );

        n = csvread( fullPN );
        e = csvread( fullPE );

        if i==1

            N = n;
            E = e;

        else

            N = padconcatenation( N, n, 1 );
            E = padconcatenation( E, e, 1 );

        end

        cnt( i ) = size( n, 1 );

    end

else
    
    N = csvread( [path 'sceneNodes.csv'] );
    E = csvread( [path 'sceneEdges.csv'] );
    cnt = size(N,1);
    
end
