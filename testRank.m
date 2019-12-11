function result = testRank()

% Load test data and labels
% testData = csvread( 'imgsetRawNodeData1.csv' );
% classLabels = csvread( 'imgsetNodeLabels1.csv' );
% instanceLabels = csvread( 'imgsetInstanceLabels1.csv' );
% testData = csvread( 'realNodeData.csv' );
% classLabels = csvread( 'realNodeLabels.csv' );
% instanceLabels = csvread( 'realInstanceLabels.csv' );
testData = csvread( 'goodSymData1.csv' );
classLabels = csvread( 'goodSymLabels1.csv' );
instanceLabels = csvread( 'goodSymInstLabels1.csv' );

classNum = max( classLabels );
graphNum = max( instanceLabels );
nodeCnt = length( classLabels );

% 1 - Breakpoint; 2 - Information contained; 3 - Number; 4 - No rank
% reduction; 5 - Interative

varNum = size( testData, 2 );

for i =1:classNum;
    classNodeCnt( i ) = sum( classLabels == i );
end

graphClassLabels = ones( 1, graphNum );

for i=2:classNum
        
    graphClassLabels( max( instanceLabels( classLabels == i-1 ) ) + 1:end ) = graphClassLabels( max( instanceLabels( classLabels == i-1 ) ) + 1:end ) + 1;
    
end

%Rest of the methods
methodNum = 3;

redoBest = 1;

if redoBest == 1
    
    disp( 'Getting DA' )

    % Iterative Rank
    Transform = getSCCDATransform( testData, classLabels, instanceLabels );

    nMin = 10;%int32( ceil( varNum * 0.05 ) );
    nMax = 40;%int32( ceil( varNum * 0.5 ) );

    disp( 'Rank Testing' )

    for nn=1:nMax-nMin+1
        
        str = sprintf( 'Iter number: %d', nn );
        
        disp( str )

        Data = testData*Transform{nn};

        % Load models
        for i=1:classNum

        %     Model{ i } = csvread( sprintf( 'model%d.csv', i ) );

            [ classes, ClusterCenters ] = clusterNodes( Data( classLabels == i, : ) );

            Model{ i } = createGraphModel( classes, ClusterCenters, classNodeCnt( i ) );

            modelNodeCnt( i ) = size( Model{ i }, 1 );

        end

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

        finalScores = zeros( graphNum, 3 );

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


            % Test for recognizing the classes

            % Punish if the entire object is misclassified
            % Majority of labels
            finalScores( i, 2 ) = double( mode( labels( currInd, 1 ) ) == currClass );


        end

        res( nn, : ) = mean( finalScores, 'omitNaN' );
        
        res( nn, 3 ) = size( Data, 2 );

        score( nn ) = res( nn, 1 ) + res( nn, 2 );

    end

    result( methodNum + 2, : ) = res( find( score == max( score ), 1, 'first'), : );

end

for method=0:methodNum
    
    disp( 'Alternative Method' )
    
    [ Data, ~, ~ ] = getPCA( testData, 0.99, classLabels, instanceLabels, 4, method );
    
    % Load models
    for i=1:classNum

    %     Model{ i } = csvread( sprintf( 'model%d.csv', i ) );

        [ classes, ClusterCenters ] = clusterNodes( Data( classLabels == i, : ) );

        Model{ i } = createGraphModel( classes, ClusterCenters, classNodeCnt( i ) );

        modelNodeCnt( i ) = size( Model{ i }, 1 );

    end

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

    finalScores = zeros( graphNum, 3 );

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



        % Punish if the entire object is misclassified
        % Majority of labels
        finalScores( i, 2 ) = double( mode( labels( currInd, 1 ) ) == currClass );
        finalScores( i, 3 ) = size( Data, 2 );


    end

    result( method+1, : ) = mean( finalScores, 'omitNaN' );
    
end