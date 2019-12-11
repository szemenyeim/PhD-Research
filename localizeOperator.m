function [ outLabels, fval ] = localizeOperator( scene, method )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Get costs
global Costs 
global classNum
global Distances
global crossOverMethod
global mutateRatio
global dragRatio

Costs = getNodeCosts( scene );
nodeNum = size( scene, 1 );

% Setup globals

Labels = double(Costs == min(Costs,[],2));
Labels = reshape( Labels, 1, classNum*nodeNum );
popSize = nodeNum*10;
initPop = randomInit( nodeNum*classNum, popSize);

crossOverMethod = 0;

% GA   
if method == 0
    
    mutateRatio = 1;
    dragRatio = 0;
    
    options = gaoptimset( 'Display', 'off', 'InitialPopulation', initPop, 'MutationFcn', @crossover_mutate, 'CrossoverFcn', @crossover, ...
        'PopulationSize', popSize, 'CrossoverFraction', 0.6, 'StallGenLimit', 20 );
    
    [ Labels, fval, exitFlag, output ] = ga( @ga_fitness, classNum*nodeNum, options );
    
    Labels = reshape( Labels, size( Costs ) );
    
% BnB
elseif method == 1
    
  dragRatio = 0.3;
  mutateRatio = 0.7;
  
  options = gaoptimset( 'Display', 'off', 'InitialPopulation', initPop, 'MutationFcn', @crossover_mutate, 'CrossoverFcn', @crossover, ...
        'PopulationSize', popSize, 'StallGenLimit', 20 );
    
  [ Labels, fval, exitFlag, output ] = ga( @ga_fitness, classNum*nodeNum, options );
    
  Labels = reshape( Labels, size( Costs ) );

end

[ rowi, coli ] = find(Labels==1);

outLabels(rowi)=coli;

