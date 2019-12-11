% Create pool of nodes for classes
% Probabilities of appearance
Prototypes = [
    1 1 1 1 0 0 0 0 0 0 0 0;
    0 0 0 0 1 1 1 1 0 0 0 0;
    0 0 0 0 0 0 0 0 1 1 1 1
];

PosTypes = [0.2 0 0; -0.2 0 0; 0 1 1];
OrTypes = [1 0 0; 0 1 0; 0.7071 0.7071 0];

p = 'locDatasets/syn3/';

distScale = 4;

noiseScale = 0.05;

% Create pool of common random nodes

for class=1:3    

    % Create instances
    ClassInst = [];
    ClassPos = [];

    for i=1:1000

        curr = [];
        currPos = [];
        for j=1:3

             curr = [ curr Prototypes( mod(class + j-2, 3)+1, : ) + randn(1,12) * noiseScale .* Prototypes( mod(class + j-2, 3)+1, : )];
             currPos = [ currPos ( PosTypes(j,:) + randn(1,3 ) .* distScale * noiseScale ) normr( OrTypes(j,:) + randn(1,3 ) * noiseScale ) ];


        end

        numDist = 0;
        if( rand(1) > 0.7 )
            numDist = 1;
        end

        for j=1:numDist

            curr = [ curr ( randn(1,12 ) .* Prototypes( randi([1 3], 1 ), : ) ) ];
            currPos = [ currPos (randn(1,3 ) .* distScale / 5 ) normr( randn(1,3 ) ) ];                

        end

        len = size( curr, 2 );

        if( len < 48 )

            curr = [curr zeros( 1, 48-len)];
            currPos = [currPos zeros( 1, 24-size( currPos, 2 ))];

        end

        ClassInst = [ClassInst; curr];
        ClassPos = [ClassPos; currPos];

    end

    csvwrite( [p sprintf('%d',class) 'nodes.csv'], ClassInst );
    csvwrite( [p sprintf('%d',class) 'centers.csv'], ClassPos );
    
end
