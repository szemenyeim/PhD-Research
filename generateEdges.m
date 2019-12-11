numCat = 5;
numNodes = 10;
len = numNodes * numNodes * 2;

for dsCntr=10:29

    path = sprintf( 'locDatasets/syn%d/', dsCntr );

    for i=1:numCat
        fName = sprintf( '%s%dcenters.csv', path, i );
        Centers = csvread(fName);

        Edges = [];
        for j=1:size(Centers,1)
            edge = [];

            currCent = Centers(j,:);
            currCent = reshape(currCent,6,[])';
            for k=1:size(currCent,1)
                if nnz(currCent(k,:)) == 0
                    break;
                end
                for l=1:size(currCent,1)
                    
                    if nnz(currCent(l,:)) == 0
                        break;
                    end

                    dist = (currCent(l,1:3)-currCent(k,1:3))*(currCent(l,1:3)-currCent(k,1:3))';
                    angle = currCent(l,4:6)*currCent(k,4:6)';

                    edge = [edge dist angle];

                end    
            end
            
            if length(edge) < len
                edge = [edge zeros(1,len - length(edge))];
            end

            Edges = [Edges; edge];

        end

        fName2 = sprintf( '%s%dedges.csv', path, i );
        csvwrite(fName2, Edges);

    end
end