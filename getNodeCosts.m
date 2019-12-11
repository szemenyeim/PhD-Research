function [ Costs ] = getNodeCosts( nodeData )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

global classNum
global scalingFactor
nodeCnt = size( nodeData, 1 );

Costs = zeros( nodeCnt, classNum );

global models
global useSVM

if useSVM == 1

    [~,Costs] = models.Mdl.predict(nodeData);
    Costs = ones(size(Costs)) - softmax(scalingFactor*Costs')';
    
else
    for i=1:classNum

        %fName = sprintf( 'Data/catModel%d.csv', i );

        M = models{i};%csvread( fName );

        for j=1:nodeCnt

            diff = repmat( nodeData( j, : ), size( M, 1 ), 1 ) - M;
            Costs( j, i ) = min(diag(diff*diff'));

        end

    end

    maxMtx = repmat( max(Costs')', 1, classNum );

    Costs = Costs ./ maxMtx;
end

end

