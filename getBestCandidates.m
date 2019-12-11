function [ candidates ] = getBestCandidates( population, N, useGA, orig )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if useGA > 0
    
    options = gaoptimset( 'Display', 'off', 'InitialPopulation', population, 'MutationFcn', @crossover_mutate, 'CrossoverFcn', @crossover, ...
        'PopulationSize', size(population,1), 'CrossoverFraction', 0.6, 'StallGenLimit', 20 );
    
    [ ~, ~, ~, ~, population, costs ] = ga( @ga_fitness, size(population,2), options );
    
else
    
    costs = zeros( size( population, 1 ) );
    
    for i=1:size( population, 1 )
       
        costs(i) = ga_fitness( population( i, : ) );
        
    end
    
end

% Get N best mutations
[~,ind] = sort( costs );
candidates = zeros( N+1, size(population,2));
candidates(1, :) = orig;
cntr = 1;
for j=1:size(population,1)
    
    isUnique = true;
    for k=1:cntr
        
        if population(ind( j ), : ) == candidates(cntr,:)
            isUnique = false;
            break;
        end
        
    end
    
    if isUnique
        cntr = cntr + 1;
        candidates( cntr, : ) = population( ind( j ) , : );
    end
    
    if cntr == N + 1
        break;
    end
    
end

end

