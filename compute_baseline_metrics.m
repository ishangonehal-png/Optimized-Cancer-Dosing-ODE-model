function baseline = compute_baseline_metrics(theta_hat, data, config)
% COMPUTE_BASELINE_METRICS Compute toxicity metrics from paper's schedule
%
% Simulates the paper's original dosing schedule to establish baseline
% metrics for toxicity constraints.
%
% Inputs:
%   theta_hat - Calibrated biological parameters
%   data      - Experimental data
%   config    - Optimization configuration
%
% Returns:
%   baseline - Struct containing:
%       .tumor_burden : Area under tumor volume curve
%       .AUC          : Area under drug concentration curve
%       .Cmax         : Peak drug concentration
%       .total_dose   : Total drug administered (mg/kg)
%       .t_sim        : Simulation time points
%       .V_sim        : Simulated tumor volumes
%       .C_sim        : Simulated drug concentrations

% Simulate paper's dosing schedule
[baseline.t_sim, baseline.V_sim, baseline.C_sim] = simulate_tumor_with_conc(...
    theta_hat.a, theta_hat.K, theta_hat.k_kill, theta_hat.k_e, ...
    data.V0, data.t_data(1), data.T_horizon, ...
    data.dose_times, data.dose_amounts);

% Compute toxicity metrics
baseline.tumor_burden = trapz(baseline.t_sim, baseline.V_sim);
baseline.AUC = trapz(baseline.t_sim, baseline.C_sim);
baseline.Cmax = max(baseline.C_sim);
baseline.total_dose = sum(data.dose_amounts);

% Store dosing schedule
baseline.dose_times = data.dose_times;
baseline.dose_amounts = data.dose_amounts;

% Display results
fprintf('Baseline (paper schedule) metrics:\n');
fprintf('  Tumor burden (AUC): %.2f\n', baseline.tumor_burden);
fprintf('  Drug AUC: %.2f\n', baseline.AUC);
fprintf('  Peak concentration (Cmax): %.2f\n', baseline.Cmax);
fprintf('  Total dose: %.2f mg/kg\n', baseline.total_dose);

end
