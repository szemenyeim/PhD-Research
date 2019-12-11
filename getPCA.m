function [ Data, Transform, Means ] = getPCA( A, Frac, classIndices, graphLabels, method, rankMethod )

if size(A,1) == length(classIndices)
    classLabels = classIndices; 
else
    classLabels = zeros( 1, size( A, 1 ) );

    for i=1:length( classIndices ) - 1

        classLabels( classIndices( i ):end ) = classLabels( classIndices( i ):end ) + 1;

    end
end
    
if method == 5
    
    [Transform, Data, Vars, Tsq, Expl, Means ] = pca( A );

    numOfFeatures = size( Data, 2 );
    currFrac = 0;

    for i=1:numOfFeatures

        currFrac = currFrac + Expl( i );
        if ( currFrac > Frac * 100 )

            numberOfComponents = i;
            break;

        end
    end

    Data = Data( :, 1:numberOfComponents );
    Transform = Transform (:, 1:numberOfComponents );

    
    indices = getWilksDimensions( Data, classLabels, graphLabels );
    Data = Data( :, indices );
    Transform = Transform( :, indices );
    
    Data = Data( :, 1:100 );
    Transform = Transform( :, 1:100 );

% Data = csvread( 'Data/PCAData.csv' );
% 
% Transform = csvread( 'Data/PCATransform.csv' );

elseif method == 6

    Data = A;
    Means = 0;
    Transform = eye(size(A,2));

else
    
    Trans = getSDATransform( A, classLabels, graphLabels, method, rankMethod );
    %Trans = getSCCDATransform( A, classLabels, graphLabels );

    %Transform =  Transform * Trans;

    Data = A * Trans;

    Transform = Trans;
    Means = 0;

end

