N=10000000;
rng('default');
x=rand(N,1);
y=rand(N,1);
z=rand(N,1);
dist=0;
tic
spmd
    trozo=floor((N)/numlabs);
    if labindex<numlabs
        ini=(labindex-1)*trozo+1;
        fin=labindex*trozo;
    else
        ini=(labindex-1)*trozo+1;
        fin=N-1;
    end
    for i=ini:fin
        dist=dist+sqrt((x(i+1)-x(i))^2+(y(i+1)-y(i))^2+(z(i+1)-z(i))^2);
    end
end
toc
% reduccion
distf = 0;
for i=1:numel(ini)
    distf = distf + dist{i};
end
distf