function [ population ] = initPopulation( seed, N )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

n = length(seed);

population = zeros( N, n );

for i=1:N
    
    population(i, :) = reshape( ga_mutate( seed ), 1, n);
    
end

end

