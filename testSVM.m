
paths = {'locDatasets/syn/','locDatasets/syn2/','locDatasets/img/','locDatasets/cad/'};

methodStr = ['noV';'vec';'mtx'];

for i=1:3
    for j=1:3
         models = load([paths{i} methodStr(j, :) 'catModel.mat']);
         
         Scene = csvread([paths{i} methodStr(j, :) 'scenePCAData.csv']);
         Train = csvread([paths{i} methodStr(j, :) 'PCAData.csv']);
         TrainLab = csvread([paths{i} 'NodeLabels.csv']);
         
         SceneNodeLabels = csvread( [paths{i} 'sceneLabels.csv'] );
         SceneInstanceLabels = csvread( [paths{i} 'sceneInstanceLabels.csv'] );
         nodeCnt = length(SceneInstanceLabels);

        % Convert Scene instance labels to indices
         SceneInstanceIndices = 1;
         for k=2:nodeCnt

             if( SceneInstanceLabels(k) ~= SceneInstanceLabels(k-1) )

                 SceneInstanceIndices = [SceneInstanceIndices k ];

             end

         end

         sceneCnt = length(SceneInstanceIndices);

         SceneInstanceIndices = [SceneInstanceIndices nodeCnt+1 ];

         trueLabels = [];
         for k=1:length(SceneInstanceIndices)-1
             trueLabels = [trueLabels SceneNodeLabels(k,1:SceneInstanceIndices(k+1)-SceneInstanceIndices(k))];
         end
         
         res((i-1)*3 + j, 1) = loss( models.Mdl, Train, TrainLab );
         res((i-1)*3 + j, 2) = loss( models.Mdl, Scene, trueLabels );
         
        
    end
end