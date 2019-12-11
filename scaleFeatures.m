function [ Nv, Ev, means, var ] = scaleFeatures( NodeVec, EdgeVec, inM, inV )

method = 1;

featNumN = size( NodeVec, 2);
featNumE = size( EdgeVec, 2);

if method == 0
    
    Nv = log10( NodeVec + 1  );
    Ev = log10( [ EdgeVec( :, 1 ) + 1 ( EdgeVec( :, 2 ) .^ 2 + 1 ) ] );
elseif method == 1
    
    if isempty(inM)
        means = zeros( 1, featNumN + featNumE );
        var = zeros( 1, featNumN + featNumE );
        for i=1:featNumN            
            var(i) = sqrt(NodeVec(:,i)'*NodeVec(:,i)/nnz(NodeVec(:,i)));
        end       
        for i=1:featNumE            
            var(featNumN + i) = sqrt(EdgeVec(:,i)'*EdgeVec(:,i)/nnz(EdgeVec(:,i)));
        end    
        
    else
       means = inM; 
       var = inV;         
    end
    
    var(var==0)=1;
    Nv = (NodeVec-means(1:featNumN))./var(1:featNumN);
    Ev = (EdgeVec-means(featNumN + 1:end))./var(featNumN + 1:end);    
    
else
    
    if isempty(inM)
        m = mean( NodeVec );
        sd = std( NodeVec );
    else
       m = inM(1:featNumN); 
       sd = inV(1:featNumN);         
    end
    sd(sd==0)=1;
    Nv = (NodeVec-repmat(m, size(NodeVec, 1), 1))./repmat(sd, size(NodeVec, 1), 1);
    %Nv = NodeVec./repmat(sd, size(NodeVec, 1), 1);
    
    means = m;
    var = sd;
    
   if isempty(inM)
        m = mean( EdgeVec );
        m( 1 ) = 0;
        sd = std( EdgeVec );
    else
       m = inM(featNumN+1:end); 
       sd = inV(featNumN+1:end);         
    end
    sd(sd==0)=1;
    Ev = (EdgeVec-repmat(m, size(EdgeVec, 1), 1))./repmat(sd, size(EdgeVec, 1), 1);
    %Ev = EdgeVec./repmat(sd, size(EdgeVec, 1), 1);
    
    means = [means m];
    var = [var sd];
    
end