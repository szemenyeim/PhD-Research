function Objects = optimizeCostFun( PCAData, NodeVec, EdgeVec, Models )

% compute individual object clusters
ObjPool = getObjectClusters( PCAData, NodeVec, EdgeVec, Models );

ObjCnt = size( ObjPool, 1 );

method = 0;

nodeCnt = size( nodeVec, 1 );

% set up edge matrix
EdgeMat = reshape( EdgeVec( :, 1 ), [ nodeCnt, nodeCnt ] );

% read up requirements
Requirements = struct( 'neighbor', csvread( 'neighbor.csv' ),  'catCnt', csvread( 'catCnt.csv' ), 'nodePcnt', csvread( 'nodePcnt.csv' ) );

% bottom - up
if method < 1 
        
    selected = zeros( Objcnt, 1 );
    
    % for all objects
    for i=1:ObjCnt
        
        % set up node vector
        nodes( i ) = zeros( nodeCnt );
        
        objNodeCnt = size( ObjPool{ i }.Nodes, 1 );
        
        for j=1:objNodeCnt
            
            nodes( i, ObjPool{ i }.Nodes( j, 1 ) ) = 1;
            
        end
    
        % get cost function and find max
        good( i ) = computeSetupGoodness( ObjPool{ i }, ObjPool{ i }.goodness, nodes( i, : ), EdgeMat, Requirements );
        
        
    end
    
    [ maxV, maxInd ] = max( good );
    
    Objects = ObjPool{ maxInd };
    
    currNodes = nodes( maxInd, : );
    
    nodeGoodnesses = ObjPool{ maxInd }.goodness;
    
    selected( maxInd ) = 1;
    
    objCntr = 1;
    
    % while cost function increases
    while true
        
        newGoods = zeros( objCnt, 1 );
        
        % for all remaining objects
        for i=1:objCnt
        
            if selected( i ) == 1
                break
            end
            
            % modify the Node vector
            tempNode = zeros( nodeCnt );
        
            objNodeCnt = size( ObjPool{ i }.Nodes, 1 );

            for j=1:objNodeCnt

                tempNode( ObjPool{ i }.Nodes( j, 1 ) ) = 1;

            end
            
            tempNodes( i ) = [ currNodes; tempNode ];
            tempGoods( i ) = [ nodeGoodnesses; ObjPool{ i }.goodness ];
            tempObjects{ objCntr + 1 } = ObjPool{ i };
        
            % get cost Function Increase
            newGoods( i ) = computeSetupGoodness( tempObjects, tempGoods( i, : ), tempNodes( i, : ), EdgeMat, Requirements );
            
        
        end
        
        % if no increase, break
        [ newMG, newInd ] = max( newgoods );
        
        if newMG <= maxV
            break
        end
        
        % add max object
        maxV = newMG;
        
        objCntr = objCntr + 1;
        Objects{ objCntr } = ObjPool{ newInd };
        
        currNodes = tempNodes( newInd );
        nodeGoodnesses = tempgoods( i );
        
    
    end
    
% top - down    
else
    
    % set up initial Objects
    
    % while cost function increases
    
    % remove the object that decreases the cost function most
    
        
end
