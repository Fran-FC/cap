clear
rng('default');
n=1000;
m=300;
k=40;
A=gpuArray.rand(n,m)*10;
W=gpuArray.rand(n,k)*10;
H=gpuArray.rand(k,m)*10;

rows1=gpuArray((1:n)');
cols1=gpuArray(1:k);

rows2=gpuArray((1:k)');
cols2=gpuArray(1:m);


function factor1=mif(i, j, aux1, aux2)
    if (aux1(i,j)/aux2(i,j)>0)
        factor1(i,j)=W(i,j)*aux1(i,j)/aux2(i,j);
    else
        factor1(i,j)=0;
    end    
end

function factor2=mif2(i, j, aux3, aux4)
    if (aux3(i,j)/aux4(i,j)>0)
       factor2(i,j)=H(i,j)*aux3(i,j)/aux4(i,j);
    else
        factor2(i,j)=0;
    end 
end

for iter=1:20
    aux1=A*H';
    aux2=W*H*H';
    W = arrayfun(@mif, rows1, cols1, aux1, aux2);

    aux3=W'*A;
    aux4=W'*W*H;
    H = arrayfun(@mif2, rows2, cols2, aux3, aux4);

    err=norm(A-W*H)
end

err
