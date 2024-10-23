% Script for checking stability of Linear system


% Initial guesses
Xudot = -1.697;
Yvdot = -22.5;
Yrdot = 0;
Nrdot = -6.58;

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

% Adding some damping coefficients for stability
T_sway = 1;
T_yaw = 1;
g = 9,81;
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

eigvals = eig(A);

% Display the eigenvalues
disp(eigvals);

% Check stability
if all(real(eigvals) < 0)
    disp('The system is stable.');
else
    disp('The system is unstable.');
end