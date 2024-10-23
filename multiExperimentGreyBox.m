clear all
% ---- CSV-file to iddata object ----

% Define the sampling time
SamplingTime = 0.1;   % Got the sampling time from cheking data. [s]

% Data 1, forward test
data1 = readtable('sorted_data\\fixed_00000218.csv');
outputs1 = data1{:, {'surge', 'sway', 'yaw_rate', 'surge_dot', 'sway_dot', 'yaw_acc'}};  % Outputs (e.g., 3 outputs)
inputs1 = data1{:, {'left_force', 'right_force'}};     % Inputs (e.g., 2 inputs)
data_id1 = iddata(outputs1, inputs1, SamplingTime);

% Data 2, forward test
data2 = readtable('sorted_data\\fixed_00000220.csv');
outputs2 = data2{:, {'surge', 'sway', 'yaw_rate', 'surge_dot', 'sway_dot', 'yaw_acc'}};  % Outputs (e.g., 3 outputs)
inputs2 = data2{:, {'left_force', 'right_force'}};     % Inputs (e.g., 2 inputs)
data_id2 = iddata(outputs2, inputs2, SamplingTime);

% Data 3, spin right test
data3 = readtable('sorted_data\\fixed_00000228.csv');
outputs3 = data3{:, {'surge', 'sway', 'yaw_rate', 'surge_dot', 'sway_dot', 'yaw_acc'}};  % Outputs (e.g., 3 outputs)
inputs3 = data3{:, {'left_force', 'right_force'}};     % Inputs (e.g., 2 inputs)
data_id3 = iddata(outputs3, inputs3, SamplingTime);

% Data 4, spin left test
data4 = readtable('sorted_data\\fixed_00000228.csv');
outputs4 = data4{:, {'surge', 'sway', 'yaw_rate', 'surge_dot', 'sway_dot', 'yaw_acc'}};  % Outputs (e.g., 3 outputs)
inputs4 = data4{:, {'left_force', 'right_force'}};     % Inputs (e.g., 2 inputs)
data_id4 = iddata(outputs4, inputs4, SamplingTime);


% Estimating the misdata
data_id_estimated1 = misdata(data_id1);
data_id_estimated2 = misdata(data_id2);
data_id_estimated3 = misdata(data_id3);
data_id_estimated4 = misdata(data_id4);


data_multi = merge(data_id_estimated1, data_id_estimated2, data_id_estimated3, data_id_estimated4);



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

% Set bounds on estimated params
lowerBounds = [-200; -200; -200; -200; -200; -200]; % Adjust as per your model
upperBounds = [0; 0; 0; 0; 0; 0];                  % Upper bounds set to 0 (parameters must stay negative)
nonLinearModel = setpar(nonLinearModel, 'Minimum', lowerBounds);
nonLinearModel = setpar(nonLinearModel, 'Maximum', upperBounds);

opt = nlgreyestOptions('Display', 'on');
nonLinearModel = nlgreyest(data_multi, nonLinearModel, opt);

% Plot a comparison between the estimated model and the measured data
compare(data_multi, nonLinearModel);

% Display the estimated parameters
disp('Estimated Parameters:');
getpar(nonLinearModel)
