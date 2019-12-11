function [ kern ] = RWK( N1,N2,E1,E2,Nv,Ev,wS,dW )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% Get sizes
nc1 = size(N1,1);
nc2 = size(N2,1);
prodSize = nc1*nc2;
N = 4;

% Get direct product ajd
A = zeros(prodSize);
for i=1:prodSize
    
    ffInd = mod(i-1,nc1)+1;
    sfInd = int32(floor((i-1)/nc1)+1);
    
    for j=i:prodSize
    
        fsInd = mod(j-1,nc1)+1;
        ssInd = int32(floor((j-1)/nc1)+1);
        
        A(i,j) = 1/(1+dW*(E1(fsInd,1) + E2(ssInd,1) + E1((fsInd-1)*nc1+ffInd,1) + E2((ssInd-1)*nc2+sfInd,1)))*exp(-Ev*((E1((fsInd-1)*nc1+ffInd,2) - E2((ssInd-1)*nc2+sfInd,2))^2));
        A(j,i) = A(i,j);
        
    end
end

% Get direct product node
e = zeros(prodSize,1);
for i=1:nc1    
    for j=1:nc2
        
        e((j-1)*nc1+i) = exp(-Nv*( (N1(i,:)-N2(j,:))*(N1(i,:)-N2(j,:))' ));
        
    end
end

% Get final result
kern = 0;

for i=0:N
   
    w(i+1) = exp(-wS*i);
    
end

%0
kern = kern + w(1)*e(1);
%1
kern = kern + w(2)*e'*A(:,1);
%2
AA = A*A(:,1);
kern = kern + w(3)*e'*AA;
%3
AAA = A*AA;
kern = kern + w(4)*e'*AAA;
%4
AAAA = A*AAA;
kern = kern + w(5)*e'*AAAA;

end

