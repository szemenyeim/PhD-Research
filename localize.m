function [ outLabels, fval ] = localize( scene, method )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Get costs
global Costs 
global classNum
global Distances
global crossOverMethod

Costs = getNodeCosts( scene );
nodeNum = size( scene, 1 );

% Setup globals

Labels = double(Costs == min(Costs,[],2));

% Greedy
if method == 0
%if method < 3
    
    % random init
    %Labels = zeros( size( Costs ) );

%     indices = int32( rand( size( Costs, 1 ), 1 ) * ( size( Costs, 2 ) + 0.99 ) );
%     indices( indices < 1 ) = 1;
%     indices( indices > classNum ) = classNum;
% 
%     for j=1:size( Costs, 1 )
% 
%        Labels( j, indices( j ) ) = 1;
% 
%     end
    
    fval = 1e+50;
    
    [Labels2,currCost] = greedy_mutate( Labels );
    
    while currCost < fval
        
        Labels = Labels2;
        fval = currCost;
        [Labels2,currCost] = greedy_mutate( Labels );
        
    end
end
% GA   
if method == 1
    
    Labels = reshape( Labels, 1, classNum*nodeNum );
    
    crossOverMethod = 1;
    
    popSize = nodeNum*10;
    initPop = Labels;
    for i=2:popSize
       
        initPop = [initPop; ga_mutate(Labels, 0.7, 0) ];
    end
    
    options = gaoptimset( 'Display', 'off', 'InitialPopulation', initPop, 'MutationFcn', @crossover_mutate, 'CrossoverFcn', @crossover, ...
        'PopulationSize', popSize, 'CrossoverFraction', 0.6, 'StallGenLimit', 20 );
    
    [ Labels, fval, exitFlag, output ] = ga( @ga_fitness, classNum*nodeNum, options );
    
    Labels = reshape( Labels, size( Costs ) );
    
% SA
elseif method == 2
    
  % random init
%   Labels = zeros( size( Costs ) );
%     
%   indices = int32( rand( size( Costs, 1 ), 1 ) * ( size( Costs, 2 ) + 0.99 ) );
%   indices( indices < 1 ) = 1;
%   indices( indices > classNum ) = classNum;
%     
%   for j=1:size( Costs, 1 )
%        
%        Labels( j, indices( j ) ) = 1;
%         
%   end
  
  Labels = reshape( Labels, classNum*nodeNum, 1 );
  opt = struct( 'Generator',@ga_mutate, 'Verbosity', 0, 'MaxConsRej', 2000 );
  
  [ Labels, fval ] = anneal( @ga_fitness, Labels, opt );
  Labels = reshape( Labels, nodeNum, classNum );
    
% BnB
elseif method == 3
    
 % random init
  Labels = reshape( Labels, 1, classNum*nodeNum );
    
  crossOverMethod = 1;
    
  popSize = nodeNum*10;
%   initPop = Labels;
%   for i=2:popSize       
%       initPop = [initPop; ga_mutate(Labels, 1, 0) ];
%   end
    
  initPop = randomInit( nodeNum*classNum, popSize);
  options = gaoptimset( 'Display', 'off', 'InitialPopulation', initPop, 'MutationFcn', @crossover_mutate, 'CrossoverFcn', @crossover, ...
        'PopulationSize', popSize, 'StallGenLimit', 20 );
    
  [ Labels, fval, exitFlag, output ] = ga( @ga_fitness, classNum*nodeNum, options );
    
  Labels = reshape( Labels, size( Costs ) );

end

[ rowi, coli ] = find(Labels==1);

outLabels(rowi)=coli;

