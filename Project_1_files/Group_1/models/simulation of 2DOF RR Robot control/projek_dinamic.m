clear variables; close all; clc

t=linspace(0,10,1000);

% Robot Definition
l1 = 5;
l2 = 5;
m1 = 2;
m2 = 2;

% inverse Linear Jacobian
inv_JL=@(t1,t2) [ -1./(l2.*sin(t1 + t2) + l1.*sin(t1)), -1./(l2.*sin(t1 + t2));  1./(l2.*cos(t1 + t2) + l1.*cos(t1)),  1./(l2.*cos(t1 + t2))];
dJL=@(t1,t2,dt1,dt2) [ - l2.*cos(t1 + t2).*(dt1 + dt2) - l1.*cos(t1).*dt1, -l2.*cos(t1 + t2).*(dt1 + dt2);
 - l2.*sin(t1 + t2).*(dt1 + dt2) - l1.*sin(t1).*dt1, -l2.*sin(t1 + t2).*(dt1 + dt2)];

% define start and end position
X0 = [1 1] ;
Xf = [3 3] ;

% build motion plan
[X,Y, X_dot, Y_dot, X_2dot, Y_2dot] = Motion_plan(X0,Xf,t);
v = [X_dot; Y_dot];
a = [X_2dot; Y_2dot];

% inverse kinematics 
q = inv_kin(X,Y,l1,l2);

% clac joint speed and acceleration 
dq_theoretic = zeros(2, length(t));
ddq_theoretic = zeros(2, length(t));
tau = zeros(2, length(t));

for i = 1:length(t)
    dq_theoretic(:,i)= inv_JL(q(1,i),q(2,i)) * q(:,i);
    ddq_theoretic(:,i)= inv_JL(q(1,i),q(2,i))*(a(i)-dJL(q(1,i),q(2,i),dq_theoretic(1,i),dq_theoretic(2,i))*dq_theoretic(:,i));
    tau(:,i)= dynamics_H_new(q(:,i)) * ddq_theoretic(:,i) + dynamics_C_new(q(:,i),dq_theoretic(:,i))*dq_theoretic(:,i)+dynamics_G_new(1);
end

% check tau plot
% plot(t, tau(1,:))
% hold on
% plot(t, tau(2,:))

%%
t_vec = t;

% tau1=[zeros(1,length(t_vec)); 1*ones(1,length(t_vec))];

% Speed Initial condition
q0 = q(:,1)';
dq0 = dq_theoretic(:,1)';

% q0=[0 0];
% dq0=[0 0];

options = odeset('MaxStep',0.1);  % adjust solver options
tau=double(tau);

% solve for Tau
[tm,X1] = ode45(@(tm,X1) state_eq_new(tm,X1,t_vec,tau),[0 5],[q0(1) dq0(1) q0(2) dq0(2)]', options);

plot_Robot(X1,l1,l2,X1(1,:),X1(2,:),5,5,0)
