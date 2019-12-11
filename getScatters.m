function [ Sbc, Swg ] = getScatters( ScData, Data, ClassLabels, InstanceLabels, onlyClosest, justBWClass )



allowance = 1.25;

classNum = max( ClassLabels );

for i=1:max(InstanceLabels)
    
    nodeCnt( i ) = sum( InstanceLabels == i );
    
end

for i=1:classNum
    
    subclassCnt( i ) = size( ScData{ i }, 1 );
    
end

Sbc = zeros( size( Data, 2 ) );

len = 0;

for i=1:classNum   
    
    for k=1:len        
       fprintf('\b');
    end
    str = sprintf('Get subclass scatter for class %d of %d',i,classNum);
    fprintf(str);
    len = length(str);
    
    for j=1:subclassCnt( i )
        for k=i:classNum                       
            
            diffVecs = ScData{ k } - repmat( ScData{ i }( j, : ), subclassCnt( k ), 1 );
            
            if onlyClosest ~= 0
                                
                norms = sum( diffVecs.^2, 2 );
                
                mins = min( norms );
                
            end
            
            for l=1:subclassCnt( k )
                
                if onlyClosest == 0
                     if ( justBWClass == 0 || i ~= k ) 
                     
                         Sbc = Sbc + ( diffVecs( l, : ) )' * ( diffVecs( l, : ) );
                                                  
                     end
                else
                    
                    if( i ~= k && norms( l ) <= mins * allowance )
                        
                        Sbc = Sbc + ( diffVecs( l, : ) )' * ( diffVecs( l, : ) );
                        
                    end
                    
                    
                end
                
            end
        end
    end
end

Swg = zeros( size( Data, 2 ) );

len = 0;

fprintf('\n');

count = max( InstanceLabels );

for i=1:count
    
    for k=1:len        
       fprintf('\b');
    end
    str = sprintf('Get within instance scatter for instance %d of %d',i,count);
    fprintf(str);
    len = length(str);
    
    normFactor = sum( InstanceLabels == i ) - 1;
    
    Swg = Swg + cov( Data( InstanceLabels == i, : ), 1 ) * normFactor;
    
end

fprintf('\n');

