function indices = getWilksDimensions( Data, ClassLabels, InstanceLabels )

ratio = 0.5;

numNode = size( Data, 1 );

numGraph = max( InstanceLabels );

numClass = max( ClassLabels );

graphClassLabels = ones( 1, numGraph );

for i=2:numClass
        
    graphClassLabels( max( InstanceLabels( ClassLabels == i-1 ) ) + 1:end ) = graphClassLabels( max( InstanceLabels( ClassLabels == i-1 ) ) + 1:end ) + 1;
    
end

dimCnt = size( Data, 2 );

nFeatures = ratio * dimCnt;
                
% Compute graph means
graphMeans = grpstats( Data, InstanceLabels, {'mean'} );

% Compute node and graph counts
nodeCnt = grpstats( Data, ClassLabels, {'numel'} );
graphCnt = grpstats( graphMeans, graphClassLabels, {'numel'} );

% Compute Variance between graph Instances
classGraphVar = grpstats( graphMeans, graphClassLabels, {'var'} );

% Compute Total Variance inside the class
totalClassVar = grpstats( Data, ClassLabels, {'var'} );

% Compute partial lambda
partLambda = classGraphVar ./ totalClassVar;

% Average the lambdas (maybe multiply?)
lowerLambda = sum( partLambda .* nodeCnt ) / numNode;

% Add between graph instance variancaes for all classes (Average?)
totalGraphVar = sum( classGraphVar .* graphCnt ) / numGraph;

% Compute Total variance between graph instances
totalVar = var( graphMeans );

% Compute second part of lambda
upperLambda = totalGraphVar ./ totalVar;

% Select first N

upperLimit = 0.1;

if upperLimit < min( upperLambda )
    upperLimit = min( upperLambda * 5 );
    
end

lowerLimit = 0.1;

if lowerLimit < min( lowerLambda )
    lowerLimit = min( lowerLambda * 5 );
    
end

upperIndices = upperLambda < upperLimit;
lowerIndices = lowerLambda < lowerLimit;

indices = upperIndices | lowerIndices;
    
