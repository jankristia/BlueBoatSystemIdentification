function [xdot, y] = BBNonLinModel(t, x, T, Xudot, Yvdot, Nrdot, Xu, Yv, Nr, varargin)

% t = current time
%
% x = [u v r]
%
%  u:     surge velocity          (m/s)
%  v:     sway velocity           (m/s)
%  r:     yaw velocity            (rad/s)
%
%  T = [ T(1) T(2) ]' where
%    T(1): thrust on left motor (N)
%    T(2): thrust on right motor (N)
% 
% p =  [Xudot Yvdot Nrdot Xu Yv Nr], params to be estimated




if nargin == 0
    x = zeros(3,1); T = zeros(2,1);
end

% Check of input and state dimensions
if (length(x) ~= 3),error('x vector must have dimension 3!'); end
if (length(T) ~= 2),error('n vector must have dimension 2!'); end

% State variables, surge, sway and yaw
u = x(1);
v = x(2);
r = x(3);
nu = x(1:3);

% Boat data
m = 15;
l1 = -0.285; % arm of left thruster
l2 = 0.285; % arm of right thruster
xg = 0.1; % x-coordinate of center of gravity, pulled a bit backwards because of batteries and motors
Iz = 1.7; % Calculated through approximating the boat as two rectangles

% Mass matrix
M = [m - Xudot, 0, 0;
    0, m - Yvdot, m*xg;
    0, m*xg, Iz - Nrdot];

% N-matrix, now using the Fossen model
N = [-Xu, -m*r, 0;
    m*r, -Yv, -Xudot*u;
    0, Xudot*u, - Nr];

% tau vector
tau = [T(1) + T(2); 0; l1*T(1) + l2*T(2)]; % Flipped the values of the yaw input

% Setting the outputs
xdot = M\(tau - N*nu);
y = [nu; xdot];

end


        
        
    















