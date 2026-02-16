function [optimal_schedule, results] = optimize_dosing_schedule(theta_hat, data, config, baseline)
% OPTIMIZE_DOSING_SCHEDULE Stage 2 - Optimize dosing with toxicity constraints
%
% Uses Bayesian optimization to find optimal dosing schedule that minimizes
% tumor burden while respecting safety constraints.
%
% Inputs:
%   theta_hat - Calibrated biological parameters from Stage 1
%   data      - Experimental data
%   config    - Optimization configuration (including toxicity limits)
%   baseline  - Baseline metrics for comparison
%
% Returns:
%   optimal_schedule - Struct containing optimized dosing parameters
%   results          - Bayesian optimization results object

%% Define decision variables
vars = [
    optimizableVariable('t_start', [config.stage2.t_start_min, config.stage2.t_start_max])
    optimizableVariable('Delta', [config.stage2.Delta_min, config.stage2.Delta_max])
    optimizableVariable('D', [config.stage2.D_min, config.stage2.D_max])
];

%% Define objective function
objective_fn = @(params) stage2_objective(params, theta_hat, data, config, baseline);

%% Run Bayesian Optimization
results = bayesopt(objective_fn, vars, ...
    'MaxObjectiveEvaluations', config.stage2.max_evals, ...
    'AcquisitionFunctionName', config.stage2.acquisition_fn, ...
    'Verbose', config.stage2.verbose, ...
    'PlotFcn', []);

%% Extract optimal parameters
x_opt = results.XAtMinObjective;
optimal_schedule.t_start = x_opt.t_start;
optimal_schedule.Delta = x_opt.Delta;
optimal_schedule.D = x_opt.D;

% Generate dose times and amounts
optimal_schedule.dose_times = optimal_schedule.t_start + ...
    (0:config.N_doses-1) * optimal_schedule.Delta;
optimal_schedule.dose_amounts = optimal_schedule.D * ones(1, config.N_doses);

% Simulate optimal schedule
[optimal_schedule.t_sim, optimal_schedule.V_sim, optimal_schedule.C_sim] = ...
    simulate_tumor_with_conc(theta_hat.a, theta_hat.K, theta_hat.k_kill, ...
    theta_hat.k_e, data.V0, data.t_data(1), data.T_horizon, ...
    optimal_schedule.dose_times, optimal_schedule.dose_amounts);

% Compute metrics
optimal_schedule.tumor_burden = trapz(optimal_schedule.t_sim, optimal_schedule.V_sim);
optimal_schedule.AUC = trapz(optimal_schedule.t_sim, optimal_schedule.C_sim);
optimal_schedule.Cmax = max(optimal_schedule.C_sim);
optimal_schedule.total_dose = sum(optimal_schedule.dose_amounts);

% Display results
fprintf('\n=== Optimal Dosing Schedule ===\n');
fprintf('Start time: %.2f days\n', optimal_schedule.t_start);
fprintf('Spacing: %.2f days\n', optimal_schedule.Delta);
fprintf('Dose amount: %.2f mg/kg (vs %.0f mg/kg baseline)\n', ...
    optimal_schedule.D, data.D_paper);
fprintf('Dose times: [%.1f, %.1f, %.1f] days\n', optimal_schedule.dose_times);
fprintf('Total drug: %.2f mg/kg (vs %.2f baseline)\n', ...
    optimal_schedule.total_dose, baseline.total_dose);

end


function cost = stage2_objective(params, theta_hat, data, config, baseline)
% STAGE2_OBJECTIVE Objective function for dosing optimization
%
% Minimizes tumor burden subject to toxicity constraints

t_start = params.t_start;
Delta = params.Delta;
D = params.D;

% Generate dose schedule
dose_times = t_start + (0:config.N_doses-1) * Delta;
dose_amounts = D * ones(1, config.N_doses);

% Check if last dose exceeds time horizon
if dose_times(end) > data.T_horizon
    cost = 1e12;  % infeasible
    return;
end

try
    % Simulate tumor growth with drug concentration tracking
    [t_sim, V_sim, C_sim] = simulate_tumor_with_conc(...
        theta_hat.a, theta_hat.K, theta_hat.k_kill, theta_hat.k_e, ...
        data.V0, data.t_data(1), data.T_horizon, ...
        dose_times, dose_amounts);
    
    % Compute metrics
    tumor_burden = trapz(t_sim, V_sim);
    auc = trapz(t_sim, C_sim);
    cmax = max(C_sim);
    total_dose = sum(dose_amounts);
    
    % HARD CONSTRAINTS - reject if violated
    if cmax > config.toxicity.Cmax_limit || ...
       auc > config.toxicity.AUC_limit || ...
       total_dose > config.toxicity.Dtot_limit
        cost = 1e12;  % infeasible - violates safety limits
        return;
    end
    
    % SOFT PENALTIES - among feasible schedules, prefer lower toxicity
    toxicity_penalty = config.toxicity.lambda_auc * auc + ...
                       config.toxicity.lambda_peak * cmax;
    
    % Total cost
    cost = tumor_burden + toxicity_penalty;
    
catch
    cost = 1e12;
end

end
