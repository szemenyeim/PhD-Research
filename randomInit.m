function [ Population ] = randomInit( genomelength, PopulationSize )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

global Costs
global classNum

Population = [];

for i=1:PopulationSize
   
    indiv = zeros( size( Costs ) );
    
    indices = int32( rand( size( Costs, 1 ) ) * ( size( Costs, 2 ) + 0.99 ) );
    indices( indices < 1 ) = 1;
    indices( indices > classNum ) = classNum;
    
    for j=1:size( Costs, 1 )
       
        indiv( j, indices( j ) ) = 1;
        
    end
    
    Population = [ Population; reshape( indiv, 1, genomelength ) ];
    
end

end

