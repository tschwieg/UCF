% 
% Set the parameters of the problem;
% 
alpha1 = 0.50;
yh1 =  50;
yl1 = -50;
alpha2 = 0.50;
beta2 = 0.05;
yh2 = 200;
yl2 = -50;
delta = 0.95;
% 
% Initialize tolerance of solution;
% 
epsilon = 0.000001;
% 
% Lay down a grid for phi;
% 
n = 9999;
phi = [1:n]/(n+1);
% 
% Initialize value function at each point;
% 
vone(1:n) = -999999;
% 
% Initialize norm of difference in successive approximations;
% 
dnorm = 999999;
% 
% Set the counter and begin value function iteration.
% 
iter = 1;
while (dnorm >= epsilon) 
  dnorm = 0;
  vnot = vone;
  for i=1:n;
    V1=(1-delta)*(alpha1*yh1+(1-alpha1)*yl1)+delta*vnot(i);
    %
    % Find indices of updates for success and failure.
    %
    phips=phi(i)*alpha2/(phi(i)*alpha2+(1-phi(i))*beta2);
    j = round((n+1)*phips);
    if (j < 1) 
      j = 1;
    end;
    if (j > n)
      j = n;
    end;
    phipf=phi(i)*(1-alpha2)/(phi(i)*(1-alpha2)+(1-phi(i))*(1-beta2));
    k = round((n+1)*phipf);
    if (k < 1)
      k = 1;
    end;
    if (k > n)
      k = n;
    end;
    EV2 = (phi(i)*alpha2+(1-phi(i))*beta2)*vnot(j);
    EV2 = EV2+(phi(i)*(1-alpha2)+(1-phi(i))*(1-beta2))*vnot(k);
    V2 = (1-delta)*(phi(i)*(alpha2*yh2+(1-alpha2)*yl2)+...
         (1-phi(i))*(beta2*yh2+(1-beta2)*yl2))+delta*EV2;
    vone(i) = max(V1,V2);
    dnorm = dnorm+(vone(i)-vnot(i))*(vone(i)-vnot(i));
  end;
  dnorm = sqrt(dnorm);
  iter = iter + 1;
end;
% 
% Create final results for optimal policy and value function;
% 
for i=1:n;
  policy(i) = 0;
  v1star(i) = (1-delta)*(alpha1+yh1+(1-alpha1)*yl1)+delta*vone(i);
  phips = phi(i)*alpha2/(phi(i)*alpha2+(1.d0-phi(i))*beta2);
  j = round((n+1)*phips);
  if (j < 1)
    j = 1;
  end;
  if (j > n) 
    j = n;
  end;
  phipf=phi(i)*(1-alpha2)/(phi(i)*(1-alpha2)+(1-phi(i))*(1-beta2));
  k = round((n+1)*phipf);
  if (k < 1) 
    k = 1;
  end;
  if (k > n)
    k = n;
  end;
  EV2 = (phi(i)*alpha2+(1-phi(i))*beta2)*vone(j);
  EV2 = EV2+(phi(i)*(1-alpha2)+(1-phi(i))*(1-beta2))*vnot(k);
  v2star(i) = (1-delta)*(phi(i)*(alpha2*yh2+(1-alpha2)*yl2)+...
              (1-phi(i))*(beta2*yh2+(1-beta2)*yl2))+delta*EV2;
  if (v1star(i) >= v2star(i)) 
    policy(i) = 1;
  else
    policy(i) = 2;
  end;
end;
plot(phi,vone,phi,10*policy,phi,v1star,phi,v2star)
