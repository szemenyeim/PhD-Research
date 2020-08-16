objFun = zeros(5,3);
classLoss = zeros(5,3);
cvLoss = zeros(5,3);

onlyModels = 0;
isTest = 0;

%objFun = csvread( 'Results/GraphEmbed/objFuns.csv' );
%cvLoss = csvread( 'Results/GraphEmbed/cvRes.csv' );
%classLoss = csvread( 'Results/GraphEmbed/classRes.csv' );

for i=1:1
    for j=3:3
        [ objFun(i,j), classLoss(i,j), cvLoss(i,j) ] = generateGraphModels(i,j,0,1,onlyModels);
        if( isTest == 1 )
            generateGraphModels(i,j,1,1,0);
        end
    end
end

csvwrite( 'Results/GraphEmbed/objFunsImg.csv', objFun );
csvwrite( 'Results/GraphEmbed/cvResImg.csv', cvLoss );
csvwrite( 'Results/GraphEmbed/classResImg.csv', classLoss );