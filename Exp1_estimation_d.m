%integral of angular velocity
integral_styro = 38.4146; 
integral_steel = 835.246;

%parameter for damping calculation
g = 9.81;
mB_steel = 0.139;
MB_styrofoam = 0.0047;
mR = 0.0447;
mA = 0.4;
lR = 0.566;
s = 0.01;
rB_steel = 0.0345;
rB_styrofoam = 0.035;
l_steel = lR-s+rB_steel;
l_styrofoam = lR-s+rB_styrofoam;

%initial and final angle of deflection from measurement data
phi_steel_1 = deg2rad(44.275);
phi_steel_2 = deg2rad(16.35);
phi_styro_1 = deg2rad(38.875);
phi_styro_2 = deg2rad(1.2);

%Calculation of damping coeffiecient
damping_steel_math = (mB_steel*l_steel*g)*(cos(phi_steel_2)-cos(phi_steel_1))/integral_steel;
damping_steel_phy = (mB_steel*l_steel+mR*lR/2)*g*(cos(phi_steel_2)-cos(phi_steel_1))/integral_steel;
damping_styro_math = (MB_styrofoam*l_styrofoam*g)*(cos(phi_styro_2)-cos(phi_styro_1))/integral_styro;
damping_styro_phy = (MB_styrofoam*l_styrofoam+mR*lR/2)*g*(cos(phi_styro_2)-cos(phi_styro_1))/integral_styro;