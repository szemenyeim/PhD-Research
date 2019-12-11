function [ Idx, C ] = smartCluster( Data, ClassLabels, InstanceLabels )

method = 0;

classNum = max( ClassLabels );
warning('off','stats:kmeans:FailedToConverge')

for i=1:classNum
    
    largestInstIdx = mode( InstanceLabels( ClassLabels == i ) );    
    
    if method == 0

        options = statset('maxiter', 1 );
        [ Idx{ i }, C{ i } ] = kmeans( Data( ClassLabels == i, : ), [], 'Options', options, 'Start', Data( InstanceLabels == largestInstIdx, : ) ); 

    else      

        [ Idx{ i }, C{ i } ] = kmeans( Data( ClassLabels == i, : ), [], 'Start', Data( InstanceLabels == largestInstIdx, : ) );

    end
end
warning('on','stats:kmeans:FailedToConverge')