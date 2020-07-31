C= [0 2 7 2 3;
1 3 9 3 3;
1 3 3 1 2;
4 0 1 0 2;
0 0 3 0 0;];

[iz, unfeas, D] = bghungar(C);

for i  = 1:size(C,1)
    fprintf('%d -> %d\n',i,iz(i));
end