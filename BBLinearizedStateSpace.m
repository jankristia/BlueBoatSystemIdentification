function [A, B, C, D] = BBLinearizedStateSpace(p, Ts)

Xudot = p(1);
Yvdot = p(2);
Yrdot = p(3);
Nrdot = p(4);

% Cruise speed we want to linearize about
Umax = 3; % max speed [m/s]
U = 1/5 * Umax; % cruise speed to liearize about [m/s]

% Boat data
m = 15;
l1 = -0.285; % arm of left thruster
l2 = 0.285; % arm of right thruster
xg = 0.1; % x-coordinate of center of gravity, pulled a bit backwards because of batteries and motors
Iz = 3.87; % Calculated through approximating the boat as two rectangles

% Mass matrix
M = [m - Xudot, 0, 0;
    0, m - Yvdot, m*xg - Yrdot;
    0, m*xg - Yrdot, Iz - Nrdot];

% Check if M is singular or near-singular
if rcond(M) < 1e-5
    error('Mass matrix M is singular or near-singular!');
end


% Adding some damping coefficients for stability
% This way of calculations is from 
T_sway = 1;
T_yaw = 1;
g = 9.81;
Xu = - 24.4 * g/Umax;
Yv = - M(2,2)/T_sway;
Nr = - M(3,3)/T_yaw;

% Coriolis matrix
Crb = [-Xu, 0, 0;
        0, -Yv, m*U;
        0, 0, m*xg*U-Nr];
Ca = [0, 0, 0;
        0, 0, -Xudot*U;
        0, (Xudot - Yvdot)*U, -Yrdot*U];
Ctot = Crb + Ca;

A = -M\Ctot;

B = M\[1, 1;
    0, 0;
    -l1, -l2];
C = eye(3);
D = zeros(3,2);

% If Ts is not 0, then it's discrete-time
    if Ts > 0
        [A, B, C, D] = c2d(A, B, C, D, Ts);  % Discretize for a sampled system
    end

end


        
        
    















