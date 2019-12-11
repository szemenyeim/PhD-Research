function A = assembleGraphMatrix( N, E, method )

global NodeFeatureCount

num = size( N, 1 );

if method == 3

    featureCnt = NodeFeatureCount + 2;

    A = zeros( num * featureCnt );

    for i=1:num


        for j=1:num

                A( ( i - 1 ) * featureCnt + 1 : i * featureCnt , ( j - 1 ) * featureCnt + 1 : j * featureCnt ) = graphKernel( N( i, : ), N( j, : ), E( i, : ), E( j, : ), E( ( i - 1 )* num + j, : ), NodeFeatureCount );

        end

    end

elseif method == 2
        
    A = [];
    
    for i=1:num
       
        A = [A;(1/(1+(E(i,1)/2)))*[N(i,:)';E(i,2)]];
        %A = [A;[N(i,:)';E(i,2)]];
        
    end
    
else
        
      A = N( 1, : );  
        
end