function Transform = getSDATransform( Data, ClassLabels, InstanceLabels, method, rankMethod )

justBWClass = 1;

classNum = max( ClassLabels );

dataNum = size( Data, 1 );

varNum = size( Data, 2 );

% 0 - LDA, 1 - SCDA, 2 - SDA, 3 - SDA + Smart Clustering, 4 - SSCDA
% method = 0;

fprintf('Clustering\n');

if method > 2
    
    [ ~, means ] = smartCluster( Data, ClassLabels, InstanceLabels );
    
else

    
    % Cluster nodes
    for i=1:classNum
       
       if method < 2
          
           means{ i } = mean( Data( ClassLabels == i, : ) );
           
           indices = sum( ClassLabels == i );
          
       else
                      
            [ indices, means{ i } ] = clusterNodes( Data( ClassLabels == i, : ) );
           
       end

       for j=1:size( means{ i }, 1 )

           N( i, j ) = sum( indices == j );

       end

    end

end

% Compute between-class scatter
% Sb = zeros( varNum );
% 
% for i=1:classNum
%     for j=1:size( means{ i }, 1 )
%         for k=i:classNum
%             for l=1:size( means{ k }, 1 )
%                 
%                 if ( justBWClass == 0 || i ~= k ) 
%                 
%                     Sb = Sb + ( ( N( i, j ) * N( k, l ) ) / ( dataNum ) ) * ( means{ i }( j, : ) - means{ k }( l, : ) )' * ( means{ i }( j, : ) - means{ k }( l, : ) );
%                 end
%             end
%         end
%     end
% end
% 
% Swg = zeros( size( Data, 2 ) );
% 
% for i=1:max( InstanceLabels )
%     
%     normFactor = sum( InstanceLabels == i ) - 1;
%     
%     Swg = Swg + cov( Data( InstanceLabels == i, : ), 1 ) * normFactor;
%     
% end
% 
% [ U, S, V ] = svd( Swg );
% 
% S( S < max( max(S) )*0.01 ) = 0;
% 
% Swg = U*S*V';

if method == 1 || method == 4
    
    iLabels = InstanceLabels;
    
else
    
    iLabels = [];
    
end

fprintf('Get scatters\n');

[ Sbc, Swg ] = getScatters( means, Data, ClassLabels, iLabels, method == 4, justBWClass );

% Compute total scatter
Sw = cov( Data, 1 ) * ( dataNum - 1 );
    
% [U,Sig,~] = svd( Sb );
% 
% Sig( Sig < 1e-10 ) = 0;
% 
% Sb = U*Sig*U';

% Compute discriminatory matrices

fprintf('Perform DA\n');

% Perform rank selection
if nnz(Swg) > 0
    
    if rankMethod == 0 %breakpoint

        [ U, S, V ] = svd( Swg );

        %S( S < min( min(S(S~=0)) )*2 ) = 0;

        S( S < max( max(S) )*0.02 ) = 0;

        Swg = U*S*V';

    elseif rankMethod == 1 % info retained

        ratio = 0.2;
        
        [ U, S, V ] = svd( Dwg );
        
        totalInfo = sum ( diag( S ) );
        
        retainedInfo = 0;
        
        for i=1:size( S, 1 )
           
            retainedInfo = retainedInfo + S( i, i );
            
            if retainedInfo > totalInfo * ratio
                
                k = i;
                
                break;
                
            end
            
        end
        
        S( k + 1:end, k + 1:end ) = zeros( size( S, 1 ) - k );        
        
        Dwg = U*S*V';


    elseif rankMethod == 2 % number
        
        [ U, S, V ] = svd( Dwg );

        number = -classNum;
        
        for i=1:classNum
           
            number = number + size( means{ i }, 1 );
            
        end
        
        S( number + 1:end, number + 1:end ) = zeros( size( S, 1 ) - number );        
        
        Dwg = U*S*V';

    else % iter
        

    end

end


[ U, S, V ] = svd( Sbc );

%S( S < min( min(S(S~=0)) )*2 ) = 0;

S( S < max( max(S) )*0.02 ) = 0;

Sbc = U*S*V';

Swinv = pinv( Sw );

Dbc = Swinv * Sbc;

Dwg = Swinv * Swg;

% Perform DA
S = 100 * Dbc + Dwg;

[ V, E ] = eig( S );

V = real( V );

E = real( E );

e = abs( diag( E ) );

ind = e > ( min( e ) + ( max( e ) - min( e ) ) / 1000 );

Transform = V( :, ind );