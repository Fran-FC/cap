clear
rng('default');
n=1000;
m=300;
k=40;
A=rand(n,m)*10;
W=rand(n,k)*10;H=rand(k,m)*10;
tic
for iter=1:20
    aux1=A*H';
    aux2=W*H*H';
    for i=1:n
        for j=1:k
            if (aux1(i,j)/aux2(i,j)>0)
               W(i,j)=W(i,j)*aux1(i,j)/aux2(i,j);
            else
                W(i,j)=0;
            end    
        end
    end
    aux3=W'*A;
    aux4=W'*W*H;
    for i=1:k
        for j=1:m 
            if (aux3(i,j)/aux4(i,j)>0)
               H(i,j)=H(i,j)*aux3(i,j)/aux4(i,j);
            else
                H(i,j)=0;
            end 
        end
    end   
    err=norm(A-W*H)
end
toc
err