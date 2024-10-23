clear all
% ---- CSV-file to iddata object ----

% Load the CSV file into a table
data = readtable('sorted_data\\full_dataset.csv');

% Extract the input and output data from the table
% time = data.original_timestamp;      % Time column
outputs = data{:, {'surge', 'sway', 'yaw_rate', 'surge_dot', 'sway_dot', 'yaw_acc'}};  % Outputs (e.g., 3 outputs)
inputs = data{:, {'left_force', 'right_force'}};     % Inputs (e.g., 2 inputs)

% Define the sampling time
SamplingTime = 0.1;   % Got the sampling time from cheking data. [s]

% Create the iddata object
data_id = iddata(outputs, inputs, SamplingTime);

% Assuming 'data_id' is your iddata object
% nan_inputs = isnan(data_id.u);   % Check for NaN values in the inputs
nan_outputs = isnan(data_id.y);  % Check for NaN values in the outputs

data_id_estimated = misdata(data_id);

% Plot the data
% plot(validation_dataset);

% ---- Make greybox object of model ----

% Making an idnlgrey object
FileName      = 'BBNonLinModel';       % File describing the model structure.
Order         = [6 2 3];           % Model orders [ny nu nx].
Parameters    = [-0.17; -22.5; -4; -79.78; -37.5; -6];         % Initial parameters. Calculated from Fossens Otter
InitialStates = [0; 0; 0];            % Initial initial states.
Ts            = 0;                 % Time-continuous system.
nonLinearModel = idnlgrey(FileName, Order, Parameters, InitialStates, Ts);


% Spesifying input and output names and units
set(nonLinearModel, 'InputName', {'Left Thruster', 'Right Thruster'}, 'InputUnit', {'N', 'N'},               ...
          'OutputName', {'Surge', 'Sway', 'Yaw Rate', 'Surge_dot', 'Sway_dot', 'Yaw_dot'}, ...
          'OutputUnit', {'m/s', 'm/s', 'rad/s', 'm/s^2', 'm/s^2', 'rad/s^2',},                         ...
          'TimeUnit', 's');
      
% Setting names and units of the initial states and parameters
nonLinearModel = setinit(nonLinearModel, 'Name', {'Surge' 'Sway' 'Yaw'});
nonLinearModel = setinit(nonLinearModel, 'Unit', {'m/s' 'm/s' 'rad/s'});
nonLinearModel = setpar(nonLinearModel, 'Name', {'Xudot' 'Yvdot' 'Nrdot' 'Xu' 'Yv' 'Nr'});
nonLinearModel = setpar(nonLinearModel, 'Unit', {'Unitless' 'Unitless' 'Unitless'  'Unitless' 'Unitless' 'Unitless'});

% Get information of the model
get(nonLinearModel)

% ---- Doing the estimation ----

% Set the absolute and relative error tolerances small
nonLinearModel.SimulationOptions.AbsTol = 1e-6;
nonLinearModel.SimulationOptions.RelTol = 1e-5;

% Doing the actual estimation
nonLinearModel = setinit(nonLinearModel, 'Fixed', {true, true, true}); % Estimate the initial states.
% Example: Set all parameters to have a lower bound of -100 and an upper bound of 0
lowerBounds = [-200; -200; -200; -200; -200; -200]; % Adjust as per your model
upperBounds = [0; 0; 0; 0; 0; 0];                  % Upper bounds set to 0 (parameters must stay negative)
% Set the bounds using setpar
nonLinearModel = setpar(nonLinearModel, 'Minimum', lowerBounds);
nonLinearModel = setpar(nonLinearModel, 'Maximum', upperBounds);

opt = nlgreyestOptions('Display', 'on');
nonLinearModel = nlgreyest(data_id_estimated, nonLinearModel, opt);

% Plot a comparison between the estimated model and the measured data
compare(data_id_estimated, nonLinearModel);

% Display the estimated parameters
disp('Estimated Parameters:');
getpar(nonLinearModel)
