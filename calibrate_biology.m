function [theta_hat, results] = calibrate_biology(data, config)
% CALIBRATE_BIOLOGY Stage 1 - Calibrate biological parameters
%
% Uses Bayesian optimization to fit Gompertz tumor growth model with
% drug pharmacokinetics to treated experimental data.
%
% Inputs:
%   data   - Experimental tumor growth data
%   config - Optimization configuration
%
% Returns:
%   theta_hat - Struct containing calibrated parameters (a, K, k_kill, k_e)
%   results   - Bayesian optimization results object

%% Define optimization variables
vars = [
    optimizableVariable('a', [config.param_ranges.a_min, config.param_ranges.a_max])
    optimizableVariable('K', [config.param_ranges.K_min, config.param_ranges.K_max])
    optimizableVariable('k_kill', [config.param_ranges.k_kill_min, config.param_ranges.k_kill_max], ...
        'Transform', 'log')  % Log transform for better sampling
    optimizableVariable('k_e', [config.param_ranges.k_e_min, config.param_ranges.k_e_max])
];

%% Define objective function
objective_fn = @(params) stage1_objective(params, data);

%% Run Bayesian Optimization
results = bayesopt(objective_fn, vars, ...
    'MaxObjectiveEvaluations', config.stage1.max_evals, ...
    'AcquisitionFunctionName', config.stage1.acquisition_fn, ...
    'Verbose', config.stage1.verbose, ...
    'PlotFcn', [], ...
    'UseParallel', false);

%% Extract calibrated parameters
theta_hat.a = results.XAtMinObjective.a;
theta_hat.K = results.XAtMinObjective.K;
theta_hat.k_kill = results.XAtMinObjective.k_kill;
theta_hat.k_e = results.XAtMinObjective.k_e;

end


function cost = stage1_objective(params, data)
% STAGE1_OBJECTIVE Objective function for parameter calibration
%
% Fits model predictions to experimental data using log least squares

a = params.a;
K = params.K;
k_kill = params.k_kill;
k_e = params.k_e;

try
    % Simulate tumor growth with paper's dosing schedule
    [t_sim, V_sim, ~] = simulate_tumor_with_conc(a, K, k_kill, k_e, ...
        data.V0, data.t_data(1), data.t_data(end), ...
        data.dose_times, data.dose_amounts);
    
    % Interpolate simulation at data points
    V_sim_at_data = interp1(t_sim, V_sim, data.t_data, 'linear', 'extrap');
    
    % Check for invalid values
    if any(V_sim_at_data <= 0) || any(isnan(V_sim_at_data)) || any(isinf(V_sim_at_data))
        cost = 1e10;
        return;
    end
    
    % Log least squares objective (better for exponential growth)
    cost = sum((log(V_sim_at_data) - log(data.V_trt_data)).^2);
    
catch
    % Penalize if simulation fails
    cost = 1e10;
end

end
