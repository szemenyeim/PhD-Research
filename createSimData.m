function createSimData( )

% Set up Node mean vectors and appearance probabilities
Np = [ 1 0.9 0.9 0.8 0.8; 
       1 0.9 0.8 0.8 0;
       1 0.95 0.9 0 0;
       1 0.9 0.8 0 0;
       1 0.99 0.95 0.95 0 ];

n = 100;
   
N = rand( 25, n );

x = 90;

N( 2:5, 1:x ) = repmat( N( 1, 1:x ), 4, 1 );
N( 7:10, 1:x ) = repmat( N( 6, 1:x ), 4, 1 );
N( 12:15, 1:x ) = repmat( N( 11, 1:x ), 4, 1 );
N( 17:20, 1:x ) = repmat( N( 16, 1:x ), 4, 1 );
N( 22:25, 1:x ) = repmat( N( 21, 1:x ), 4, 1 );

% offs = randn( 4, n-x );
% 
% N( 2:5, x+1:end ) = repmat( N( 1, x+1:end ), 4, 1 ) + offs;

N( 2:5, x+1:end ) = rand( 4, n-x );

N( [ 6 11 16 21 ], x+1:end ) = repmat( N( 1, x+1:end ), 4, 1 ); 
N( [ 7 12 17 22 ], x+1:end ) = repmat( N( 2, x+1:end ), 4, 1 ); 
N( [ 8 13 18 23 ], x+1:end ) = repmat( N( 3, x+1:end ), 4, 1 ); 
N( [ 9 14 19 24 ], x+1:end ) = repmat( N( 4, x+1:end ), 4, 1 ); 
N( [ 10 15 20 25 ], x+1:end ) = repmat( N( 5, x+1:end ), 4, 1 ); 

% mixes = rand( 1, x );
% 
% for ind = 1:x;
% 
%     N( :, ind ) = mixes( ind ) .* N( :, ind ) + ( 1 - mixes( ind ) ) .* N( :, x + ind );
% 
% end
% 
% N = N( :, 1:x );

%N( 2:25, 51:100 ) = repmat( N( 1, 51:100 ), 24, 1 );

%N = N + randn( 25, 100 ) / 100;

N = N - repmat( mean( N ), size( N, 1 ), 1 );

%create graphs and labels
graphNodes = [];
classLabels = [];
instanceLabels = 0;

for i=1:5
    for j=1:400
        
        dice = rand( 1, 5 );
        
        select = find( Np( 1, : ) > dice ) + ( i - 1 ) * 5;
        
        graphNodes = [ graphNodes; N( select, : ) + randn( length( select ), n ) / 10 ];
        
        classLabels = [ classLabels; i * ones( length( select ), 1 ) ];
        
        instanceLabels = [ instanceLabels; ( max( instanceLabels ) + 1 ) * ones( length( select ), 1 ) ];
        
    end
end

instanceLabels = instanceLabels( 2:end );

csvwrite( 'Data/goodsymLabels2.csv', classLabels );
csvwrite( 'Data/goodsymInstLabels2.csv', instanceLabels );
csvwrite( 'Data/goodsymData2.csv', graphNodes );


% means1 = [ 1 0 0.1 0 0 0.1; 0 1 0.1 0 0 0.1; -1 0 0.1 0 0 0.1; 0 -1 0.1 0 0 0.1 ];
% means2 = [ 1 0 0 0.1 0 0; 0 1 0 0.1 0 0; -1 0 0 0.1 0 0; 0 -1 0 0.1 0 0 ];
% means3 = [ 1 0 0 0 0.1 0; 0 1 0 0 0.1 0; -1 0 0 0 0.1 0; 0 -1 0 0 0.1 0 ];
% 
% n = [ 20 20 20 20 2 20; 20 20 2 20 20 2; 20 20 2 20 20 20 ];
% 
% i=1:4800;
% 
% classLabels = floor( ( i - 1 ) / 1600 ) + 1;
% 
% instanceLabels = floor( ( i - 1 ) / 4 ) + 1;
% 
% N1 = [];
% N2 = [];
% N3 = [];
% 
% for i=1:400
%    
%     N1 = [ N1; means1 + randn( 4, 6 ) ./ repmat( n( 1, : ), 4, 1 ) ]; 
%     N2 = [ N2; means2 + randn( 4, 6 ) ./ repmat( n( 2, : ), 4, 1 ) ];
%     N3 = [ N3; means3 + randn( 4, 6 ) ./ repmat( n( 3, : ), 4, 1 ) ];
%     
% end
% 
% graphNodes = [ N1; N2; N3 ];
% 
% csvwrite( 'Data/goodsymLabels1.csv', classLabels );
% csvwrite( 'Data/goodsymInstLabels1.csv', instanceLabels );
% csvwrite( 'Data/goodsymData1.csv', graphNodes );

% means1 = [ 1 0 0 2 0 0; 0 2 0 1 0 0; -1 0 0 -2 0 0; 0 -2 0 -1 0 0 ];
% means2 = [ 0.5 0 0 3 0 0; 0 1 0 4 0 0; -0.5 0 0 -3 0 0; 0 -1 0 -4 0 0 ];
% 
% n = [ 20 20 20 20 20 20; 20 20 20 20 20 20 ];
% 
% i=1:3200;
% 
% classLabels = floor( ( i - 1 ) / 1600 ) + 1;
% 
% instanceLabels = floor( ( i - 1 ) / 4 ) + 1;
% 
% N1 = [];
% N2 = [];
% 
% for i=1:400
%    
%     N1 = [ N1; means1 + randn( 4, 6 ) ./ repmat( n( 1, : ), 4, 1 ) ]; 
%     N2 = [ N2; means2 + randn( 4, 6 ) ./ repmat( n( 2, : ), 4, 1 ) ];
%     
% end
% 
% graphNodes = [ N1; N2 ];
% 
% csvwrite( 'Data/goodsymLabels3.csv', classLabels );
% csvwrite( 'Data/goodsymInstLabels3.csv', instanceLabels );
% csvwrite( 'Data/goodsymData3.csv', graphNodes );
