function comp = computeCompactness( data, centers, indices )

numData = size( data, 1 );

comp = 0;

for i=1:numData
    
    distVec = data( i, : ) - centers( indices( i ), : );
    
    comp = comp + distVec * distVec';
    
end