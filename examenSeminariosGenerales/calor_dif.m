function calor_dif(nx) 
dz=0.05
dt=0.005
q=2
alpz=0.01
tfin=30
conc=zeros(nx+2,nx+2);
conc(2,2)=q;
conaux=conc;
iter=0;
tim=0;
tiempo_calculo=0 
 
while tim<tfin
  tim=tim+dt;
  conaux=conc;
  tic

%   conc = mex_ex(conaux, dt, alpz, dz, nx+2);
  %Este es el doble bucle que hay que optimizar o transformar en un mex
  for i=2:nx+1
   for j=2:nx+1
    conc(i,j)=conaux(i,j)+dt*(conaux(i-1,j)+conaux(i,j-1)-4*conaux(i,j)+conaux(i+1,j)+conaux(i,j+1))*alpz/(dz*dz);
    
   end
  end
  % fin del doble bucle
tiempo_calculo=tiempo_calculo+toc;
 
 
 
  if tim<10 
     conc(2,2)=q;
      end 
   iter=iter+1;
   if rem(iter,500)==1 
      contourf(conc(1:nx+1,:))
      colorbar
      tim
   end
end
tiempo_calculo


