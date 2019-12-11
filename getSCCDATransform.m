function Transform = getSCCDATransform( Data, ClassLabels, InstanceLabels )

% Init
justBWClass = 1;

classNum = max( ClassLabels );

dataNum = size( Data, 1 );

varNum = size( Data, 2 );

% Clustering

[ ~, means ] = smartCluster( Data, ClassLabels, InstanceLabels );

% Get Scatter Matrices

[ Sbc, Swg ] = getScatters( means, Data, ClassLabels, InstanceLabels, true, justBWClass );

Sw = cov( Data, 1 ) * ( dataNum - 1 );

% Compute discriminatory matrices
Swinv = pinv( Sw );

Dbc = Swinv * Sbc;

Dwg = Swinv * Swg;

% Rank handle bsc matrix

[ U, S, V ] = svd( Dbc );

%S( S < min( min(S(S~=0)) )*2 ) = 0;

S( S < max( max(S) )*0.0002 ) = 0;

Dbc = U*S*V';

nMin = 10;%int32( ceil( varNum * 0.05 ) );
nMax = 40;%int32( ceil( varNum * 0.5 ) );

for i=nMin:nMax

    % Rank handle Dwg
    [ U, S, V ] = svd( Dwg );
    
    S( i + 1:end, i + 1:end ) = zeros( size( S, 1 ) - i ); 
    
    Dwg_t = U*S*V';

    % Perform DA
    S = 100 * Dbc + Dwg_t;

    [ V, E ] = eig( S );

    V = real( V );

    E = real( E );

    e = abs( diag( E ) );

    ind = e > ( min( e ) + ( max( e ) - min( e ) ) / 1000 );

    Transform{i-nMin+1} = V( :, ind );

end