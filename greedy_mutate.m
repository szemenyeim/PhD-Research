function [ Z, currentFitness ] = greedy_mutate( X )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
global Costs

Y = reshape( X, size( Costs ) );

currentFitness = ga_fitness( Y );
Z = Y;

nodeNum = size(Y,1);
classNum = size(Y,2);

for i=1:nodeNum;
    
    %if sum( Y( i, : ) ) > 0
    %    continue;
    %end
    
    for j=1:classNum
        
        if( Y(i,j) > 0 )
            continue;
        end
        
        delta = zeros(1,classNum);
        delta(j) = 1;
        
        tried = Y;
        tried(i,:)=delta;
        
        triedFit = ga_fitness( tried );
        
        if( triedFit < currentFitness )
            Z = tried;
            currentFitness = triedFit;
        end
        
    end
end

end

