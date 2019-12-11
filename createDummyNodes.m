function [N, E] = createDummyNodes( Ni, Ei, num, means )


length = size( Ni, 1 );

nodeFeatureCnt = size( Ni, 2 );

maxD = max(Ei(:,1));

% if length == 1
%     
%     D( 1 ) = ( 10 ^ ( norm( Ni ) + 1 ) ) * 2;
%     
% end

% if method < 1 %random
%     
%     means = mean( Ni, 1 );
%     vars = var( Ni, 1 );
%     edgeMeans = mean( Ei, 1 );
%     edgeVars = var( Ei, 1 );
%     
%     if length == 1
%     
%         vars = sqrt( normrnd( Ni / 2, Ni / 2 ) .^ 2 );
%         edgeVars = sqrt( normrnd( Ei / 2, Ei / 2 ) .^ 2 );
%     
%     end
%     
%     for i=1:num
%         
%         if i <= length
%             
%             N( i, : ) = Ni( i, : );
%             
%             for j=1:length
%                 
%                 E( ( i - 1 ) * num + j, : ) = Ei( ( i - 1 ) * length + j, : );
%             
%             end
% 
%             for j=length+1:num
% 
%                 E( ( i - 1 ) * num + j, : ) = normrnd( edgeMeans, edgeVars );
%                 E( ( i - 1 ) * num + j, 1 ) = E( ( i - 1 ) * num + j, 1 ) + 2 * D( length );
% 
%             end
%             
%         else
%             
%             N( i, : ) = normrnd( means, vars );
%             
%             for j=1:length
%             
%                 E( ( i - 1 ) * num + j, : ) = normrnd( edgeMeans, edgeVars );
%                 E( ( i - 1 ) * num + j, 1 ) = E( ( i - 1 ) * num + j, 1 ) + 2 * D( length );
% 
%             end
% 
%             for j=length+1:num
% 
%                 E( ( i - 1 ) * num + j, : ) = normrnd( edgeMeans, edgeVars );
% 
%             end
% 
%         end
%               
%     end
%     
%     
% elseif method == 1 %double far nodes
%     
%     for i=1:num
%         
%         if i <= length
%             
%             N( i, : ) = Ni( i, : );
%             
%             for j=1:length
%                 
%                 E( ( i - 1 ) * num + mod( j, num ), : ) = Ei( ( i - 1 ) * length + mod( j, length ), : );
%             
%             end
% 
%             for j=length+1:num
% 
%                 E( ( i - 1 ) * num + mod( j, num ), : ) = Ei( ( i - 1 ) * length + mod( length, length ), : );
%                 E( ( i - 1 ) * num + mod( j, num ), 1 ) = E( ( i - 1 ) * num + mod( j, num ), 1 ) + 2 * D( length );
% 
%             end
%             
%         else
%             
%             N( i, : ) = N( i - 1, : );
%             
%             for j=1:length
%             
%                 E( ( i - 1 ) * num + mod( j, num ), : ) = Ei( ( length - 1 ) * length + mod( j, length ), : );
%                 E( ( i - 1 ) * num + mod( j, num ), 1 ) = E( ( i - 1 ) * num + mod( j, num ), 1 ) + 2 * D( length );
% 
%             end
% 
%             for j=length+1:num
% 
%                 E( ( i - 1 ) * num + mod( j, num ), 1 ) = 0;
%                 E( ( i - 1 ) * num + mod( j, num ), 2 ) = 0;
% 
%             end
% 
%         end
%               
%     end
    
% Fill with zeros
    
for i=1:num

    if i <= length

        N( i, : ) = Ni( i, : );

        for j=1:length

            E( ( i - 1 ) * num + j, : ) = Ei( ( i - 1 ) * length + j, : );

        end

        for j=length+1:num

            E( ( i - 1 ) * num + j, : ) = [ maxD*20 means( nodeFeatureCnt+2:end )];

        end

    else

        N( i, : ) = means( 1:nodeFeatureCnt );

        for j=1:num

            E( ( i - 1 ) * num + j, : ) = [ maxD*20 means( nodeFeatureCnt+2:end )];

        end

    end

end 