g = 9.81;   %gravitational acceleration
mB = 0.139; %mass of steel ball
lR = 0.566; %length of the rod
s = 0.01;   %screw-in length
rB = 0.0345;    %radius of the ball
l = lR-s+rB;    %ball center to bearing length
d=0;    %damping coefficient of 0
z = 2.348009729240826e-04;  %damping coefficient from measurement
omega_0 = 0;    %initial velocity
phi_0 = deg2rad(44.275);    %initial deflection angle
Fgl = mB*g*l;   %moment caused by the weight
J = mB*l*l; %inertial mass of the ball


