result = zeros(3,3,4);
cost = zeros(3,3,4);
optim = zeros(3,3,4);
class = zeros(3);

paths = {'syn10','syn11','syn12','syn13','syn14','syn15','syn16','syn17','syn18','syn19',...
'syn20','syn21','syn22','syn23','syn24','syn25','syn26','syn27','syn28','syn29'};

class = csvread( 'Results/GraphEmbed/sceneClassresL.csv' );

classNum = 5;

global contRewards
contRewards = zeros( classNum );
for i=1:20
    
    if exist(['Results/Localization/' paths{i} 'result.csv'], 'file') == 2
        result = csvread( ['Results/Localization/' paths{i} 'result.csv'] );
        if size(result, 1) == 3
            result = [result; zeros(1,4)];
        end
    else
        result = zeros(4,4);
    end
    
    if exist(['Results/Localization/' paths{i} 'costFunction.csv'], 'file') == 2
        cost = csvread( ['Results/Localization/' paths{i} 'costFunction.csv'] );
        if size(cost, 1) == 3
            cost = [cost; zeros(1,4)];
        end
    else
        cost = zeros(4,4);
    end
    
    if exist(['Results/Localization/' paths{i} 'optimFail.csv'], 'file') == 2
        optim = csvread( ['Results/Localization/' paths{i} 'optimFail.csv'] );
        if size(optim, 1) == 3
            optim = [optim; zeros(1,4)];
        end
    else
        optim = zeros(4,4);
    end
    
    for j=1:3
        for k=1:4
            
            rng default;
            
            [result(j,k), cost(j,k), optim(j,k), class(i,j) ] = testLoc(i,j,k-1,1);
            
        end
    end
    
    csvwrite( ['Results/Localization/' paths{i} 'result.csv'], result(:,:) );
    csvwrite( ['Results/Localization/' paths{i} 'costFunction.csv'], cost(:,:) );
    csvwrite( ['Results/Localization/' paths{i} 'optimFail.csv'], optim(:,:) );
    
end

%csvwrite( 'Results/GraphEmbed/sceneClassresL29.csv', class );