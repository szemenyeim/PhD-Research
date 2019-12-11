function [ res ] = dummyKernel( U,V )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

global KernelMtx

res = KernelMtx(U,V);

if res == 0
    fprintf('Accessed wrong SV in %d %d', U, V);
end

end

