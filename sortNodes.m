function [Ni, Ei] = sortNodes( N, E, index )

num = size( N, 1 );

assert( index <= num );

for i=1:num
    
   distances( i ) = E( ( i - 1 ) * num + index, 1 ); 
    
end

[ ~, indices ] = sort( distances );

for i=1:num
    
   Ni( i, : ) = N( indices( i ), : ); 
   
   for j=1:num
       
       Ei( ( i - 1 ) * num + j, : ) = E( ( indices( i ) - 1 ) * num + indices( j ), : );
       
   end
    
end