opt = zeros(20,1);
tr = zeros(20,1);
cv = zeros(20,1);
for i=1:20
    [opt(i),tr(i),cv(i)] = testRWK( i, 0, 0 );
end