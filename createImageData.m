function createImageData()

% Load all files in select folders and build graph instance labels
dirList = dir('D:/3rdPartyLibs/Databases/VML' );
flags = [ dirList.isdir ];
dirList = dirList( flags );
dirList = dirList( 3:end );

classNum = length( dirList );

cntr = 1;

imgLabels = [];

for i=1:classNum
   
    fName = sprintf( 'D:/3rdPartyLibs/Databases/VML/%s/*.jpg', dirList( i ).name );
    imgList = dir( fName );
    imgNum = length( imgList );
    
    imgLabels = [ imgLabels; i * ones( imgNum, 1 ) ];
    
    for j=1:imgNum
       
        imgName = sprintf( 'D:/3rdPartyLibs/Databases/VML/%s/%s', dirList( i ).name, imgList( j ).name );
        
        images{ cntr } = imread( imgName );
        cntr = cntr + 1;
        
    end
    
end


% Get 10 best SURF descriptors for each and build node and instance labels
totalImgNum = length( imgLabels );

nodeData = [];
edgeData = [];
rawNodeData = [];
nodeLabels = [];
instanceLabels = 0;

for i=1:totalImgNum
   
    if size( images{ i }, 3 ) > 1
        
        grayImg = rgb2gray( images{ i } );
       
    else
        
        grayImg = images{ i };
        
    end
    
    points = detectSURFFeatures( grayImg );
    points = points.selectStrongest( 15 );
    
    [ fts, ~ ] = extractFeatures( grayImg, points );
    
    pts = [];
    edges = zeros(1,15*15*2);
    
    ptsNum = size( points, 1 );
    
    if ptsNum == 0
        continue
    end
    
    for j=1:ptsNum
       
        featLoc = points( j ).Location;
        featOr = points( j ).Orientation;
        
        for k=1:ptsNum
            featLoc2 = points( k ).Location;
            featOr2 = points( k ).Orientation;
            
            edges(1,2*((j-1)*15 + mod(k-1,15)) + 1) = sqrt(sum((featLoc2 - featLoc) .^ 2));
            edges(1,2*((j-1)*15 + mod(k-1,15)) + 2) = cos((featOr-featOr2)/2);
            
        end
        
        x = int32( featLoc( 2 ) );
        y = int32( featLoc( 1 ) );
        
%         if x < 16
%             x = 16;
%         end
%         
%         if y < 16
%             y = 16;
%         end
%         
%         if x > size( grayImg, 1 ) - 16
%             x = size( grayImg, 1 ) - 16;
%         end
%         
%         if y > size( grayImg, 2 ) - 16
%             y = size( grayImg, 2 ) - 16;
%         end
%         
%         raw = grayImg( x - 15 : x + 16, y - 15 : y + 16 );
%         
%         raw = reshape( raw, 1, 1024 );
%         
%         pts = [ pts; raw ];
        
    end
    
    if ptsNum < 15
       
        fts = [ fts ; zeros( 15-ptsNum, 64 ) ];
%         pts = [ pts ; zeros( 15-ptsNum, 1024 ) ];
        
    end
    
    fts = reshape(fts,[1,15*64]);
    
    nodeData = [ nodeData; fts ];
    edgeData = [ edgeData; edges ];
%     rawNodeData = [ rawNodeData; pts ];
    nodeLabels = [ nodeLabels; imgLabels( i ) * ones( size( fts, 1 ), 1 ) ];
    instanceLabels = [ instanceLabels; ( max( instanceLabels ) + 1 ) * ones( size( fts, 1 ), 1 ) ];
    
    
end

instanceLabels = instanceLabels( 2:end );

% Save

csvwrite( 'locDatasets/img1/sceneNodes.csv', nodeData );
csvwrite( 'locDatasets/img1/sceneEdges.csv', edgeData );
%csvwrite( 'Data/imgsetRawNodeData2.csv', rawNodeData );
csvwrite( 'locDatasets/img1/NodeLabels.csv', nodeLabels );
csvwrite( 'locDatasets/img1/InstanceLabels.csv', instanceLabels );

