paths = {'locDatasets/img1/','locDatasets/img2/','locDatasets/img3/','locDatasets/img4/','locDatasets/img5/','locDatasets/img6/'};
catNums = [3 2 3 5 16 6];

for i=1:6
    
    [ Nodes, Edges, graphCnt ] = readNEData( paths{i}, 1, 1 );
    graphLabels = csvread( [paths{i} 'NodeLabels.csv'] );
    
    for j=1:catNums(i)
        
        currN = Nodes(graphLabels==j,:);
        currE = Edges(graphLabels==j,:);
        
        csvwrite(sprintf( '%s%dnodes.csv', paths{i}, j ),currN);
        csvwrite(sprintf( '%s%dedges.csv', paths{i}, j ),currE);
        
    end
    
    
end
