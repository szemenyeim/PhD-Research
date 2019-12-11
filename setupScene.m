function [ Objects, Align ] = setupScene( )

% Read up scenes, models, and the PCA V transform, and the point cloud 

[ Nodes, Edges, sceneCnt ] = readNEData( 'C:/Users/Marci/Google Drive/diploma/Matlab/scenes/', 1 );

PCAV = csvread( 'C:/Users/Marci/Google Drive/diploma/Matlab/PCATransform.csv' );

categoryCnt = 5;

for i=1:categoryCnt
    
    fName = sprintf( 'catModel%d.csv', i );
    
    Models( i, :, : ) = csvread( fName );
    
end

numOfComponents = 100;

% For all scenes        
for j=1:sceneCnt
        
    % Get Node descriptors
    [ nodeCnt, NodeVec, EdgeVec ] = countNodes( Nodes( j, : ), Edges( j, : ) );

    for k=1:nodeCnt

        [ currN, currE, D ] = sortNodes( NodeVec, EdgeVec, k );

        [ fullN, fullE ] = createDummyNodes( currN, currE, 10, D );

        DescMat = assembleGraphMatrix( fullN, fullE, 14 );

        v( k, : ) = vectorizGraph( DescMat ) ;


    end     
   
    PCAData = PCATransform( v, PCAV, numOfComponents );
    
    % Optimize cost function
    Objects = optimizeCostFun( PCAData, NodeVec, EdgeVec, Models );
    
    % Compute Alignemnt
    Align = computeAlignment( Object, PointCloudData, ModelData );
    
end
            
end