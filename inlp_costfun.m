function [ cost ] = inlp_costfun( X )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global Costs
global Distances

Y = reshape( X, size( Costs ) );

cost = sum(sum(Costs.*Y));

penalty = 0;

nodeNum = size(Y,1);

for i=1:nodeNum-1
    for j=i:nodeNum
        
        penalty = penalty + factor/Distances(i,j)*( Y( i, : )*Y(j,:)');
        
    end
end

cost = cost + penalty;

end

