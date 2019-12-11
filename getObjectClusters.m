function Objects = getObjectClusters( PCAData, NodeVec, EdgeVec, Models )

modelCnt = size( Models, 1 );

nodeCnt = size( PCAData, 1 );

objCntr = 0;

for i=1:modelCnt
    
    % compute node goodnesses
    NodeGoodnesses = computeNodeGoodness( PCAData, Models( i, :, : ) );
    
    selected = zeros( nodeCnt, 1 );
    
    modelNodeCnt = size( Nodegooness, 2 );
    
    % for as long as possible/sesible
    while true
        
        % select best node
        currSel = zeros( nodeCnt, 1 );
        
        % Get Max goodness node that is not selected
        [ maxG, ind ] = max( NodeGoodnesses( selected( : ) == 0, : ) );
        [ nodeInd, modelInd ] = ind2sub( size( NodeGoodness ), ind );
        
        % Assemble node and edge vector
        currNodes = [ nodeInd modelInd ];
        currEdges = 0;
        currGoods = maxG;
        currSel( nodeInd ) = 1;
        
        % compute cost fun
        costFun = computeGraphGoodness( currNodes, currEdges, Models( i, :, : ), currGoods );
    
        while true
               
            % iterate through all non-selected nodes and compute cost fun
            
            maxVal = costFun;
            maxInd = [ -1; -1 ];
            
            currNodeCnt = size( currNodes, 1 );
            
            for j=1:nodeCnt
                
                if selected( j ) == 1 || currSel( j ) == 1
                    continue
                end
                
                for k=1:modelNodeCnt
                    
                    newNodes = [ currNodes; j k ];
                    newGoods = [ currGoods; NodeGoodnesses( j, k ) ];
                    
                    newEdges = [ currEdges( 1:currNodeCnt, : ); EdgeVec( ( currNodes( 1, 1 ) - 1 ) * nodeCnt + j , 1 ) ];
                    
                    for l=2:currNodeCnt
                        
                        newEdges = [ newEdge; currEdges( ( l - 1 ) * currNodeCnt + 1: l * currNodeCnt, : ); EdgeVec( ( currNodes( l, 1 ) - 1 ) * nodeCnt + j , 1 ) ];
                        
                    end
                                        
                    newVal = computeGraphGoodness( newNodes, newEdges, Models( i, :, : ), newGoods );
                    
                    if newVal > maxVal
                        
                        maxVal = newVal;
                        maxInd = [ j; k ];
                        
                        bestNodes = newNodes;
                        bestEdges = newEdges;
                        bestGoods = newGoods;
                        
                    end
                    
                end
                                
            end
            
            % if no increase, break
            if maxVal <= costFun
                break
            end
            
            % get the one that increases it the most
            currNodes = bestNodes;
            currEdges = bestEdges;
            currGoods = bestGoods;
            costFun = maxVal;
                      
            % update current selection and the curr best cost fn
            currSel( maxInd( 1 ) ) = 1;
                    
        end
                
        % If the goodness is bad, break
        if costFun < minVal
            break
        end
        
        % administer node selection
        selected = selected || currSel;
        
        % add object
        newObj = struct( 'modelInd', i, 'goodness', costFun, 'Nodes', currNodes );
        
        objCntr = objCntr + 1;
        
        Objects{ objCntr } = newObj;
        
    end
    
    
end