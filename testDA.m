function result = testDA()

surfTest = 0;

% Load test data and labels
% testData = csvread( 'imgsetRawNodeData1.csv' );
% classLabels = csvread( 'imgsetNodeLabels1.csv' );
% instanceLabels = csvread( 'imgsetInstanceLabels1.csv' );
% testData = csvread( 'realNodeData.csv' );
% classLabels = csvread( 'realNodeLabels.csv' );
% instanceLabels = csvread( 'realInstanceLabels.csv' );
testData = csvread( 'symData3.csv' );
classLabels = csvread( 'symLabels3.csv' );
instanceLabels = csvread( 'symInstLabels3.csv' );

if surfTest == 1
   
    testDataSURF = csvread( 'imgsetNodeData6.csv' );
    %testData = csvread( 'imgsetRawNodeData1.csv' );
    classLabels = csvread( 'imgsetNodeLabels6.csv' );
    instanceLabels = csvread( 'imgsetInstanceLabels6.csv' );
    
end

classNum = max( classLabels );
graphNum = max( instanceLabels );
nodeCnt = length( classLabels );

% 0 - LDA, 1 - SCDA, 2 - SDA, 3 - SDA-IC, 4 - SSCDA, 5 - Wilks


for i =1:classNum;
    classNodeCnt( i ) = sum( classLabels == i );
end

graphClassLabels = ones( 1, graphNum );

for i=2:classNum
        
    graphClassLabels( max( instanceLabels( classLabels == i-1 ) ) + 1:end ) = graphClassLabels( max( instanceLabels( classLabels == i-1 ) ) + 1:end ) + 1;
    
end

methodNum = 5 + surfTest;

for method=1:4

    method_ = method;
    if method == 2
        method_ = 3;
    end
    
    disp('Getting DA')
    
    if method <= 5
        
        [ Data, ~, ~ ] = getPCA( testData, 0.99, classLabels, instanceLabels, method_, 0 );
        
    else
        
        [ Data, ~, ~ ] = getPCA( testDataSURF, 0.99, classLabels, instanceLabels, method_, 0 );
        
    end        

    disp('Computing Models')
    
    % Load models
    for i=1:classNum

    %     Model{ i } = csvread( sprintf( 'model%d.csv', i ) );

        [ classes, ClusterCenters ] = clusterNodes( Data( classLabels == i, : ) );

        Model{ i } = createGraphModel( classes, ClusterCenters, classNodeCnt( i ) );

        modelNodeCnt( i ) = size( Model{ i }, 1 );

    end

    disp('Evaluating Models')
    
    maxNodeCnt = max( modelNodeCnt );

    % Classify all nodes - classification scores padded with zeros
    scores = zeros( nodeCnt, classNum, maxNodeCnt );

    for i=1:nodeCnt
        for j=1:classNum
            for k=1:modelNodeCnt( j )

                scores( i, j, k ) = ( Data( i, : ) - Model{ j }( k, : ) ) * ( Data( i, : ) - Model{ j }( k, : ) )';

            end
        end
    end

    scores( scores == 0 ) = NaN;

    labels = zeros( nodeCnt, 2 );

    finalScores = zeros( graphNum, 6 );

    for i=1:graphNum

        currInd = find( instanceLabels == i );
        currClass = graphClassLabels( i );

        nodeNum = length( currInd );

        % Calculate Labels
        for j=1:nodeNum

            [ interMin, interIdx ] = min( reshape( scores( currInd( j ), :, : ), classNum, maxNodeCnt ), [], 2, 'omitNaN' );
            [ ~, classIdx ] = min( interMin );

            labels( currInd( j ), 1 ) = classIdx;
            labels( currInd( j ), 2 ) = interIdx( currClass );

        end

        % Test against telling apart the parts

        % # of different labels / number of nodes 
        finalScores( i, 1 ) = length( unique( labels( currInd, 2 ) ) ) / length( currInd );

        % Score the differences in scores
        % Square difference between scores normalized to one
        currCorrectScores = reshape( scores( currInd, currClass, : ), nodeNum, maxNodeCnt );

        if nodeNum == 1
            
            currCorrectScores = currCorrectScores( :, ~isnan( currCorrectScores ) );
            
        else        
        
            currCorrectScores = currCorrectScores( :, all( ~isnan( currCorrectScores ) ) );
            
        end

    %     currCorrectScores = currCorrectScores - repmat( mean( currCorrectScores, 'omitNaN' ), size( currCorrectScores, 1 ), 1 );
    %     
    %     norms = sqrt( sum( currCorrectScores.^2, 2 ) );
    %     
    %     scatter = 0;
    %     
    %     for k=1:( nodeNum - 1 )
    %         for j=k+1:nodeNum
    %             
    %             scatter = scatter + 0.5 - ( currCorrectScores( k, : ) * currCorrectScores( j, : )' ) / ( 2 * norms( k ) * norms( j ) );
    %             
    %         end
    %     end
    %     
    %     finalScores( i, 4 ) = scatter / ( nodeNum * ( nodeNum - 1 ) / 2 );    

        finalScores( i, 4 ) = classifyNodes( currCorrectScores );

        % Test for recognizing the classes

        % Punish if a node is assigned to a different model  
        % Max score is elsewhere
        finalScores( i, 2 ) = sum( labels( currInd, 1 ) == currClass ) / length( currInd );

        % Max score in correct class / Best score
        minScores = min( scores( currInd, :, : ), [], 3, 'omitNaN' );
        bestScores = min( minScores, [], 2 );
        finalScores( i, 5 ) = mean( bestScores ./ minScores( :, currClass ) );

        % Punish if the entire object is misclassified
        % Majority of labels
        finalScores( i, 3 ) = double( mode( labels( currInd, 1 ) ) == currClass );

        % Sum of max scores in correct class / Sum of best scores
        finalScores( i, 6 ) = sum( bestScores ) / sum( minScores( :, currClass ) );


    end

    result( method+1, : ) = mean( finalScores, 'omitNaN' );

end
