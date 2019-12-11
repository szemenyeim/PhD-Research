% Create pool of nodes for classes
% Probabilities of appearance
Prototypes = [
    1 1 1 0 0 0 0 0 0 0 0 0;
    0 0 0 1 1 0 0 0 0 0 0 0;
    0 0 0 0 0 1 1 0 0 0 0 0;
    0 0 0 0 0 0 0 1 1 1 0 0;
    0 0 0 0 0 0 0 0 0 0 1 1
];

p = 'locDatasets/syn10/';

Orders = [ 20 20 20 20 20 20 20 20 20 20 20 20];

distScale = 5;

noiseScale = 0.05;

indices1 = randi([1 5], 1, 3 );

Class1 = [ rand(1,12 ) .* Orders .* Prototypes( indices1(1), : );
    rand(1,12 ) .* Orders .* Prototypes( indices1(2), : );
    rand(1,12 ) .* Orders .* Prototypes( indices1(3), : ) ];

Posloc1 = [ rand( 3, 3 ) * distScale normr(rand(3,3)) ];

prob1 = [ 0.95 0.7 0.2 ];

indices2 = randi([1 5], 1, 2 );

Class2 = [ rand(1,12 ) .* Orders .* Prototypes( indices2(1), : );
    rand(1,12 ) .* Orders .* Prototypes( indices2(2), : ) ];

Posloc2 = [ rand( 2, 3 ) * distScale normr(rand(2,3)) ];

prob2 = [ 0.9 0.8 ];

indices3 = randi([1 5], 1, 3 );

Class3 = [ rand(1,12 ) .* Orders .* Prototypes( indices3(1), : );
    rand(1,12 ) .* Orders .* Prototypes( indices3(2), : );
    rand(1,12 ) .* Orders .* Prototypes( indices3(3), : ) ];

Posloc3 = [ rand( 3, 3 ) * distScale normr(rand(3,3)) ];

prob3 = [ 0.95 0.8 0.4 ];

indices4 = randi([1 5], 1, 4 );

Class4 = [ rand(1,12 ) .* Orders .* Prototypes( indices4(1), : );
    rand(1,12 ) .* Orders .* Prototypes( indices4(2), : );
    rand(1,12 ) .* Orders .* Prototypes( indices4(3), : );
    rand(1,12 ) .* Orders .* Prototypes( indices4(4), : ) ];

Posloc4 = [ rand( 4, 3 ) * distScale normr(rand(4,3)) ];

prob4 = [ 0.7 0.7 0.6 0.6 ];

indices5 = randi([1 5], 1, 5 );

Class5 = [ rand(1,12 ) .* Orders .* Prototypes( indices5(1), : );
    rand(1,12 ) .* Orders .* Prototypes( indices5(2), : );
    rand(1,12 ) .* Orders .* Prototypes( indices5(3), : );
    rand(1,12 ) .* Orders .* Prototypes( indices5(4), : );
    rand(1,12 ) .* Orders .* Prototypes( indices5(5), : ) ];

Posloc5 = [ rand( 5, 3 ) * distScale normr(rand(5,3)) ];

prob5 = [ 0.9 0.8 0.7 0.2 0.2 ];

% Create pool of common random nodes

% Create instances
Class1Inst = [];
Class1Pos = [];

for i=1:1000
   
    curr = [];
    currPos = [];
    N = size(indices1,2);
    for j=1:N
       
        if prob1(j) > rand(1)
            
            curr = [ curr ( Class1( j, : ) + randn(1,12 ) .* Orders .* Prototypes( indices1(j), : ) * noiseScale ) ];
            currPos = [ currPos ( Posloc1( j, 1:3 ) + randn(1,3 ) .* distScale * noiseScale ) normr( Posloc1( j, 4:6 ) + randn(1,3 ) * noiseScale ) ];
            
        end
        
    end
    
    if size(curr, 1 ) == 0
        continue;
    end
    
    numDist = 0;
    if( rand(1) > 0.7 )
        numDist = 1;
    end
    meanPos = mean(Posloc1);
    
    for j=1:numDist
        
        curr = [ curr ( rand(1,12 ) .* Orders .* Prototypes( randi([1 5], 1, 1 ), : ) ) ];
        currPos = [ currPos (meanPos(1:3) + rand(1,3 ) .* distScale / 5 ) normr( randn(1,3 ) ) ];                
        
    end
    
    len = size( curr, 2 );
    
    if( len < 12*(N+1) )
       
        curr = [curr zeros( 1, 12*(N+1)-len)];
        currPos = [currPos zeros( 1, 6*(N+1)-size( currPos, 2 ))];
        
    end
    
    Class1Inst = [Class1Inst; curr];
    Class1Pos = [Class1Pos; currPos];
    
end

% Create instances
Class2Inst = [];
Class2Pos = [];

for i=1:1000
   
    curr = [];
    currPos = [];
    N = size(indices2,2);
    for j=1:N
       
        if prob2(j) > rand(1)
            
            curr = [ curr ( Class2( j, : ) + randn(1,12 ) .* Orders .* Prototypes( indices2(j), : ) * noiseScale ) ];
            currPos = [ currPos ( Posloc2( j, 1:3 ) + randn(1,3 ) .* distScale * noiseScale ) normr( Posloc2( j, 4:6 ) + randn(1,3 ) * noiseScale ) ];
            
        end
        
    end
    
    if size(curr, 1 ) == 0
        continue;
    end
    
    numDist = 0;
    if( rand(1) > 0.7 )
        numDist = 1;
    end
    meanPos = mean(Posloc2);
    
    for j=1:numDist
        
        curr = [ curr ( rand(1,12 ) .* Orders .* Prototypes( randi([1 5], 1, 1 ), : ) ) ];
        currPos = [ currPos (meanPos(1:3) + rand(1,3 ) .* distScale / 5 ) normr( randn(1,3 ) ) ];                
        
    end
    
    len = size( curr, 2 );
    
    if( len < 12*(N+1) )
       
        curr = [curr zeros( 1, 12*(N+1)-len)];
        currPos = [currPos zeros( 1, 6*(N+1)-size( currPos, 2 ))];
        
    end
    
    Class2Inst = [Class2Inst; curr];
    Class2Pos = [Class2Pos; currPos];
    
end

% Create instances
Class3Inst = [];
Class3Pos = [];

for i=1:1000
   
    curr = [];
    currPos = [];
    N = size(indices3,2);
    for j=1:N
       
        if prob3(j) > rand(1)
            
            curr = [ curr ( Class3( j, : ) + randn(1,12 ) .* Orders .* Prototypes( indices3(j), : ) * noiseScale ) ];
            currPos = [ currPos ( Posloc3( j, 1:3 ) + randn(1,3 ) .* distScale * noiseScale ) normr( Posloc3( j, 4:6 ) + randn(1,3 ) * noiseScale ) ];
            
        end
        
    end
    
    if size(curr, 1 ) == 0
        continue;
    end
    
    numDist = 0;
    if( rand(1) > 0.7 )
        numDist = 1;
    end
    meanPos = mean(Posloc3);
    
    for j=1:numDist
        
        curr = [ curr ( rand(1,12 ) .* Orders .* Prototypes( randi([1 5], 1, 1 ), : ) ) ];
        currPos = [ currPos (meanPos(1:3) + rand(1,3 ) .* distScale / 3 ) normr( randn(1,3 ) ) ];                
        
    end
    
    len = size( curr, 2 );
    
    if( len < 12*(N+1) )
       
        curr = [curr zeros( 1, 12*(N+1)-len)];
        currPos = [currPos zeros( 1, 6*(N+1)-size( currPos, 2 ))];
        
    end
    
    Class3Inst = [Class3Inst; curr];
    Class3Pos = [Class3Pos; currPos];
    
end

% Create instances
Class4Inst = [];
Class4Pos = [];

for i=1:1000
   
    curr = [];
    currPos = [];
    N = size(indices4,2);
    for j=1:N
       
        if prob4(j) > rand(1)
            
            curr = [ curr ( Class4( j, : ) + randn(1,12 ) .* Orders .* Prototypes( indices4(j), : ) * noiseScale ) ];
            currPos = [ currPos ( Posloc4( j, 1:3 ) + randn(1,3 ) .* distScale * noiseScale ) normr( Posloc4( j, 4:6 ) + randn(1,3 ) * noiseScale ) ];
            
        end
        
    end
    
    if size(curr, 1 ) == 0
        continue;
    end
    
    numDist = 0;
    if( rand(1) > 0.7 )
        numDist = 1;
    end
    meanPos = mean(Posloc4);
    
    for j=1:numDist
        
        curr = [ curr ( rand(1,12 ) .* Orders .* Prototypes( randi([1 5], 1, 1 ), : ) ) ];
        currPos = [ currPos (meanPos(1:3) + rand(1,3 ) .* distScale / 3 ) normr( randn(1,3 ) ) ];                
        
    end
    
    len = size( curr, 2 );
    
    if( len < 12*(N+1) )
       
        curr = [curr zeros( 1, 12*(N+1)-len)];
        currPos = [currPos zeros( 1, 6*(N+1)-size( currPos, 2 ))];
        
    end
    
    Class4Inst = [Class4Inst; curr];
    Class4Pos = [Class4Pos; currPos];
    
end

% Create instances
Class5Inst = [];
Class5Pos = [];

for i=1:1000
   
    curr = [];
    currPos = [];
    N = size(indices5,2);
    for j=1:N
       
        if prob5(j) > rand(1)
            
            curr = [ curr ( Class5( j, : ) + randn(1,12 ) .* Orders .* Prototypes( indices5(j), : ) * noiseScale ) ];
            currPos = [ currPos ( Posloc5( j, 1:3 ) + randn(1,3 ) .* distScale * noiseScale ) normr( Posloc5( j, 4:6 ) + randn(1,3 ) * noiseScale ) ];
            
        end
        
    end
    
    if size(curr, 1 ) == 0
        continue;
    end
    
    numDist = 0;
    if( rand(1) > 0.7 )
        numDist = 1;
    end
    meanPos = mean(Posloc5);
    
    for j=1:numDist
        
        curr = [ curr ( rand(1,12 ) .* Orders .* Prototypes( randi([1 5], 1, 1 ), : ) ) ];
        currPos = [ currPos (meanPos(1:3) + rand(1,3 ) .* distScale / 3 ) normr( randn(1,3 ) ) ];                
        
    end
    
    len = size( curr, 2 );
    
    if( len < 12*(N+1) )
       
        curr = [curr zeros( 1, 12*(N+1)-len)];
        currPos = [currPos zeros( 1, 6*(N+1)-size( currPos, 2 ))];
        
    end
    
    Class5Inst = [Class5Inst; curr];
    Class5Pos = [Class5Pos; currPos];
    
end
    
csvwrite( [p '1nodes.csv'], Class1Inst );
csvwrite( [p '1centers.csv'], Class1Pos );
    
csvwrite( [p '2nodes.csv'], Class2Inst );
csvwrite( [p '2centers.csv'], Class2Pos );
    
csvwrite( [p '3nodes.csv'], Class3Inst );
csvwrite( [p '3centers.csv'], Class3Pos );
    
csvwrite( [p '4nodes.csv'], Class4Inst );
csvwrite( [p '4centers.csv'], Class4Pos );
    
csvwrite( [p '5nodes.csv'], Class5Inst );
csvwrite( [p '5centers.csv'], Class5Pos );
