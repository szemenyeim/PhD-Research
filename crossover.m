function [ kids ] = crossover( parents, options, nvars, FitnessFcn, ...
    unused,thisPopulation )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
global Costs
global Distances
global distThreshold

global crossoverMethod

nodeNum = size(Costs,1);
classNum = size(Costs,2);

kids = zeros( length(parents)/2, nvars );

for i=1:length(parents)/2

    Y{1} = reshape( thisPopulation(parents(2*i-1), :), size( Costs ) );
    Y{2} = reshape( thisPopulation(parents(2*i), :), size( Costs ) );

    if crossoverMethod == 0
    
        place = randi(nodeNum,1);

        o1 = [Y{1}(1:place, :);Y{2}(place+1:end, : )];

        kids(i, :) = reshape( o1, 1, nvars );
    
    else
        
        indices = zeros(1,nodeNum);
        remaining = nodeNum - nnz(indices);
        
        thresh = 0.5;
        incFactor = 0.25;
        
        while remaining > 0
            
            if (rand(1) < thresh)                
                parent = 1;
                thresh = thresh-incFactor;                
            else                
                parent = 2;
                thresh = thresh+incFactor;
            end
            
            %parent = randi(1:2,1);
            remInd = find(indices==0);
            place = remInd(randi(remaining, 1));
            
            select = Distances( place, : ) <= distThreshold;
            select( indices > 0 ) = 0;
            indices( select ) = parent;
            remaining = nodeNum - nnz(indices);
            
        end
        
        o1 = zeros( nodeNum, classNum );
       
        for j=1:nodeNum
            
            o1(j,:) = Y{indices(j)}(j,:);
            
        end

        kids(i, :) = reshape( o1, 1, nvars );
        
    end

end
end

