function [ fitness, contMtx ] = ga_fitness( X )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
global Costs
global Distances
global contRewards
global rewards
global distThreshold

bigPunishment = 1e+40;

Y = reshape( X, size( Costs ) );

cost = sum(sum(Costs.*Y));

penalty = 0;

factor = 0.5;

nodeNum = size(Y,1);
classNum = size(Y,2);

for i=1:nodeNum-1
    for j=i+1:nodeNum
        
        labelDiff = Y( i, : ) - Y(j,:);
        
        penalty = penalty + factor/(Distances(i,j)*Distances(i,j))*( labelDiff*labelDiff');
        %penMtx(i,j) = factor/(Distances(i,j)*Distances(i,j))*( labelDiff*labelDiff');
        
    end
end

cost = cost + penalty;

% reward instance
cost = cost - (sum( Y ) > 0)*rewards;

% punish deviation from one label per node
cost = cost + ( sum( Y' ) - ones( nodeNum, 1 )' )*( sum( Y' )' - ones(nodeNum,1))*bigPunishment;

% Reward context
contMtx = zeros( classNum );

for i=1:classNum
   
    if sum(Y(:, i)) == 0
       
        %contMtx( i, ~ismember(1:classNum, i) ) = contMtx( i, ~ismember(1:classNum, i) ) - sum( Y( :,~ismember(1:classNum, i)  ) );        
        
    else
        
        for j=i+1:classNum
            for k=1:nodeNum
                
                if Y( k, i ) ~= 1
                    continue;
                end
                
                for l=1:nodeNum
                
                    if Y( l, j ) ~= 1 || l==k
                        continue;
                    end
                    
                    invDist = 1/Distances( k, l );
                    if invDist > contMtx( i, j )
                        contMtx(i,j) = invDist;
                    end
                
                end
            end
        end
        
    end
    
end

contMtx(contMtx > 0) = contMtx(contMtx > 0) - mean(reshape(contMtx, classNum*classNum, 1 ) );

cost = cost - sum(sum(contMtx.*contRewards));

fitness = cost;

end

