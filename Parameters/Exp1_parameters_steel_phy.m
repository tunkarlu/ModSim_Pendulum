g = 9.81;   %gravitational acceleration
mB = 0.139; %mass of steel ball
mR = 0.0447;    %mass of the rod
mA = 0.4;   %mass of the bearing
lR = 0.566; %length of the rod
s = 0.01;   %screw-in length
rB = 0.0345;    %radius of the ball
l = lR-s+rB;    %ball center to bearing length
JA = 3.4602e-5; %inertial mass of the bearing(given)
JB = (2*mB*rB*rB)/5 + mB*l*l;   %inertial mass of the ball
JR = (mR*lR*lR)/3;  %inertial mass of the rod
d = 0;  %damping coefficient of 0
z = 2.709885202116140e-04;  %damping coefficient from measurement
omega_0 = 0;    %initial velocity
phi_0 = deg2rad(44.275);    %initial deflection angle
Fgl = mB*g*l+mR*g*lR/2; %moment caused by the weight
J = JA+JB+JR;   %total inertial mass


