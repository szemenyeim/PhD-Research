function [ Z ] = ga_mutate( X, p, p2 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global Costs

if nargin < 3
    p=0.7;
    p2 = 0;
end

Y = reshape( X, size( Costs ) );

global dragRatio

global Distances

nodeNum = size(Y,1);
classNum = size(Y,2);

if( rand(1) < p )

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
    i=1:classNum;
    ind = randperm( classNum );
    while ind == i
        ind = randperm( classNum );
    end
    Y(:,i)=temp(:,ind(i));
    
    roll = rand(1);
    
    if( roll < p2 )
        
        place = randi( nodeNum, 1 );
        newClass = randi( classNum, 1 );

        Y( place, : ) = zeros( 1, classNum );
        Y( place, newClass ) = 1;
        
        
    end
    
end

Z = reshape ( Y, size( X ) );

end

