%result = zeros(3,3,4);
%cost = zeros(3,3,4);
%optim = zeros(3,3,4);
%class = zeros(3);

paths = {'syn10','syn11','syn12','syn13','syn14','syn15','syn16','syn17','syn18','syn19',...
'syn20','syn21','syn22','syn23','syn24','syn25','syn26','syn27','syn28','syn29', 'syn', 'syn2', 'img', 'realimg'};

classNum = 5;

global contRewards
contRewards = zeros( classNum );

ClassRes = csvread( 'Results/Localization/GAClassRes.csv' );
OptimRes = csvread( 'Results/Localization/GAOptRes.csv' );
%FinalAcc = zeros( 20, 4);
%FinalOpt = zeros( 20, 4);
%CostFun = zeros(20, 2);

for i=21:24    
    result = csvread( ['Results/Localization/' paths{i} 'result.csv'] );
    optim = csvread( ['Results/Localization/' paths{i} 'optimFail.csv'] );
    costfun = csvread( ['Results/Localization/' paths{i} 'costFunction.csv'] );
    ClassRes(i,3) = result(3,4);
    ClassRes(i,4) = result(3,2);
    OptimRes(i,3) = optim(3,4);
    OptimRes(i,4) = optim(3,2);
%     FinalAcc(i,2:4) = result(3,1:3);
%     FinalAcc(i,1) = result(1,2);
%     FinalOpt(i,2:4) = optim(3,1:3);
%     FinalOpt(i,1) = optim(1,2);
%     CostFun(i,1) = costfun(1,2);
%     CostFun(i,2) = costfun(2,3);    
end

for i=23:24
    
    for j=1:2
            
        rng default;
            
        [ClassRes(i,j), OptimRes(i,j) ] = testGALoc(i,j-1);
            
    end
    
end

csvwrite( 'Results/Localization/GAClassRes.csv', ClassRes );
csvwrite( 'Results/Localization/GAOptRes.csv', OptimRes );
% csvwrite( 'Results/Localization/FinalAcc.csv', FinalAcc );
% csvwrite( 'Results/Localization/FinalOpt.csv', FinalOpt );
% csvwrite( 'Results/Localization/CostFun.csv', CostFun );