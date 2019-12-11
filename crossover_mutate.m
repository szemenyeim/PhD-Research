function [ kids ] = crossover_mutate( parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
global Costs

global mutateRatio

global dragRatio

global Distances

for i=1:length(parents)
    Y = reshape( thisPopulation(i,:), size( Costs ) );

    nodeNum = size(Y,1);
    classNum = size(Y,2);


    roll = rand(1);

    if( roll < mutateRatio )

        place = randi( nodeNum, 1 );
        newClass = randi( classNum, 1 );

        Y( place, : ) = zeros( 1, classNum );
        Y( place, newClass ) = 1;
        
        if rand(1) < dragRatio
       
            [~,ind] = min(Distances(place,[1:place-1 place+1:end]));
            if ind >= place
                ind = ind + 1;
            end
            Y( ind, : ) = zeros( 1, classNum );
            Y( ind, newClass ) = 1;
        end        
    else
        
        temp = Y;
        ind = randperm( classNum );
        j=1:classNum;
        Y(:,j)=temp(:,ind(j));
        
    end

    kids(i,:) = reshape ( Y, 1, nvars );
end

end

