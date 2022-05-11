N=10000000;
rng('default');
x=rand(N,1);
y=rand(N,1);
z=rand(N,1);
dist=0;
tic
for i=1:N-1
    dist=dist+sqrt((x(i+1)-x(i))^2+(y(i+1)-y(i))^2+(z(i+1)-z(i))^2);
end
toc
dist
