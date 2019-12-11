
paths = {'syn','syn2','img','realimg','contimg','conreal'};

for i=5:6
    
    if exist(['Results/Localization/' paths{i} 'contResult.csv'], 'file') == 2
        result = csvread( ['Results/Localization/' paths{i} 'contResult.csv'] );
    else
        result = zeros(3,2);
    end
    
    if exist(['Results/Localization/' paths{i} 'contCost.csv'], 'file') == 2
        cost = csvread( ['Results/Localization/' paths{i} 'contCost.csv'] );
    else
        cost = zeros(3,2);
    end
    
    if exist(['Results/Localization/' paths{i} 'trainResult.csv'], 'file') == 2
        train = csvread( ['Results/Localization/' paths{i} 'trainResult.csv'] );
    else
        train = zeros(3,2);
    end
    
    if exist(['Results/Localization/' paths{i} 'valResult.csv'], 'file') == 2
        val = csvread( ['Results/Localization/' paths{i} 'valResult.csv'] );
    else
        val = zeros(3,2);
    end
    
    for j=1:3
       
        [result(j,:),cost(j,:),train(j,:),val(j,:)] = optimizeContext(i,j,1);
        
    end    
    
    csvwrite( ['Results/Localization/' paths{i} 'contResult.csv'], result );
    csvwrite( ['Results/Localization/' paths{i} 'contCost.csv'], cost );
    csvwrite( ['Results/Localization/' paths{i} 'trainResult.csv'], train );
    csvwrite( ['Results/Localization/' paths{i} 'valResult.csv'], val );
    
end