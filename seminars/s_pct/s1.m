N=1000000;
A=rand(N,1);
B=rand(N,1);
C=rand(N,1);
sol=zeros(N,2);
tic
% parpool("threads");
parfor i=1:N
    sol(i,:)=roots([A(i),B(i),C(i)]);
end
toc