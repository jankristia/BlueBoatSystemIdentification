clear all

% ---- CSV-file to iddata object ----

% Load the CSV file into a table
data = readtable('full_dataset.csv');

% Extract the input and output data from the table
% time = data.original_timestamp;      % Time column
outputs = data{:, {'surge_dot', 'sway_dot', 'yaw_acc'}};  % Outputs (e.g., 3 outputs)
inputs = data{:, {'left_force', 'right_force'}};     % Inputs (e.g., 2 inputs)

% Define the sampling time
SamplingTime = 0.1;   % Got the sampling time from cheking data. [s]

% Create the iddata object
data_id = iddata(outputs, inputs, SamplingTime);

% ---- Make greybox object of model ----

% Making an idnlgrey object
FileName      = 'BBLinearizedStateSpace';       % File describing the model structure.

% Define the sampling time
Ts = 0;  
aux = {};
% parameters = [-1.697; -22.5; 0; -6.58];  % Initial guess for the parameters
parameters = [0; 0; 0; 0];  % Initial guess for the parameters

% Create idgrey model
linearModel = idgrey(FileName, parameters, 'c', aux, Ts);


% Set bounds on estimated params
lowerBounds = [-200; -200; -200; -200]; % Adjust as per your model
upperBounds = [0; 0; 0; 0];                  % Upper bounds set to 0 (parameters must stay negative)
linearModel = setpar(linearModel, 'bounds', [lowerBounds, upperBounds]);

% Specify input and output names
set(linearModel, 'InputName', {'Left Thruster', 'Right Thruster'}, 'InputUnit', {'N', 'N'}, ...
                 'OutputName', {'Surge', 'Sway', 'Yaw'}, 'OutputUnit', {'m/s', 'm/s', 'rad/s'}, ...
                 'TimeUnit', 's');


% Perform estimation
opt = greyestOptions('Display', 'on', 'EnforceStability', true);
linearModel = greyest(data_id, linearModel, opt);

% Plot comparison between estimated model and data
compare(data_id, linearModel);

% Display the estimated parameters
disp('Estimated Parameters:');
getpar(linearModel)