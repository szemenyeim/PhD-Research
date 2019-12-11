function [ loss ] = getSVM( N,E,dummyData,graphLabels,Nv,Ev,wS,dW,BC )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global KernelMtx

global best
global iterCnt

% compute RWK

nodeCnt = size(N,1);
KernelMtx = zeros([nodeCnt nodeCnt]);

currIdx = 1;
totalCnt = nodeCnt*(nodeCnt+1)/2;

%fprintf('Computing RWK\n');

len = 0;

for i=1:nodeCnt
    for j=i:nodeCnt
        
%         for k=1:len        
%             fprintf('\b');
%          end
%         str = sprintf('Computing node %d of %d',currIdx,totalCnt);
%         fprintf(str);
%         len = length(str);
        currIdx = currIdx+1;
        
        KernelMtx(i,j) = RWK(N{i},N{j},E{i},E{j},Nv,Ev,wS,dW);
        KernelMtx(j,i) = KernelMtx(i,j);
        
    end
end
return

t = templateSVM('Standardize',0,'KernelFunction','dummyKernel','BoxConstraint',...
    BC,'CacheSize','maximal','IterationLimit',1e5);
Mdl = fitcecoc(dummyData',graphLabels,'Learners',t,'Coding','onevsall','Crossval','on','Holdout',0.2 );

loss = kfoldLoss(Mdl);
if loss < best
    best = loss;
end

str = sprintf('Loop #%0.f Finished || loss: %0.4f || best: %0.4f  || Nv: %0.4f || Ev: %0.4f || dW: %0.4f || wS: %0.4f || BC: %0.2f\n',iterCnt,loss,best,Nv,Ev,dW,wS,BC);
fprintf(str);

iterCnt = iterCnt+1;

end

