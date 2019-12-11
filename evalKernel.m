function evalKernel( N,E,SVN,SVE,Nv,Ev,wS,dW,SVs,symmetric )

global KernelMtx

% compute RWK

nodeCnt = size(N,1);
SVCnt = size(SVN,1);
KernelMtx = zeros([SVCnt nodeCnt]);
SVCnt = size(SVs,1);

len = 0;
for i=1:SVCnt
    SVIdx = int64(SVs(i));
    startIdx = 1;
    if symmetric
        startIdx = i;
    end
    for j=startIdx:nodeCnt        
        KernelMtx(SVIdx,j) = RWK(SVN{SVIdx},N{j},SVE{SVIdx},E{j},Nv,Ev,wS,dW);     
        if symmetric
            KernelMtx(j,SVIdx) = KernelMtx(SVIdx,j);
        end
    end
    for k=1:len        
       fprintf('\b');
    end
    str = sprintf('Computing RWK for SV %d of %d',i,SVCnt);
    fprintf(str);
    len = length(str);
end
fprintf('\n');