function analysis = analyze_results(theta_hat, optimal_schedule, baseline, data, config)
% ANALYZE_RESULTS Compare optimal schedule against baseline
%
% Inputs:
%   theta_hat        - Calibrated parameters
%   optimal_schedule - Optimized dosing schedule
%   baseline         - Baseline (paper) schedule metrics
%   data             - Experimental data
%   config           - Configuration
%
% Returns:
%   analysis - Struct containing comparative metrics and statistics

%% Simulate control (no treatment) for comparison
[analysis.t_ctrl, analysis.V_ctrl, ~] = simulate_tumor_with_conc(...
    theta_hat.a, theta_hat.K, theta_hat.k_kill, theta_hat.k_e, ...
    data.V0, data.t_data(1), data.T_horizon, [], []);

analysis.ctrl_burden = trapz(analysis.t_ctrl, analysis.V_ctrl);

%% Compute performance improvements
% Tumor burden reduction
analysis.baseline_reduction_pct = 100 * (analysis.ctrl_burden - baseline.tumor_burden) / analysis.ctrl_burden;
analysis.optimal_reduction_pct = 100 * (analysis.ctrl_burden - optimal_schedule.tumor_burden) / analysis.ctrl_burden;
analysis.improvement_pct = 100 * (baseline.tumor_burden - optimal_schedule.tumor_burden) / baseline.tumor_burden;

%% Toxicity constraint compliance
analysis.toxicity_compliance.Cmax_status = optimal_schedule.Cmax <= config.toxicity.Cmax_limit;
analysis.toxicity_compliance.AUC_status = optimal_schedule.AUC <= config.toxicity.AUC_limit;
analysis.toxicity_compliance.Dtot_status = optimal_schedule.total_dose <= config.toxicity.Dtot_limit;

% Utilization of safety margins
analysis.toxicity_compliance.Cmax_utilization = 100 * optimal_schedule.Cmax / config.toxicity.Cmax_limit;
analysis.toxicity_compliance.AUC_utilization = 100 * optimal_schedule.AUC / config.toxicity.AUC_limit;
analysis.toxicity_compliance.Dtot_utilization = 100 * optimal_schedule.total_dose / config.toxicity.Dtot_limit;

%% Toxicity changes (vs baseline)
analysis.toxicity_changes.Cmax_pct = 100 * (optimal_schedule.Cmax - baseline.Cmax) / baseline.Cmax;
analysis.toxicity_changes.AUC_pct = 100 * (optimal_schedule.AUC - baseline.AUC) / baseline.AUC;
analysis.toxicity_changes.Dtot_pct = 100 * (optimal_schedule.total_dose - baseline.total_dose) / baseline.total_dose;

%% Display results
fprintf('\n=== TOXICITY METRICS COMPARISON ===\n');
fprintf('                    Baseline    Optimal     Limit      Status\n');
fprintf('Peak Cmax:          %8.2f   %8.2f   %8.2f   %s\n', ...
    baseline.Cmax, optimal_schedule.Cmax, config.toxicity.Cmax_limit, ...
    status_str(analysis.toxicity_compliance.Cmax_status));
fprintf('Drug AUC:           %8.2f   %8.2f   %8.2f   %s\n', ...
    baseline.AUC, optimal_schedule.AUC, config.toxicity.AUC_limit, ...
    status_str(analysis.toxicity_compliance.AUC_status));
fprintf('Total dose (mg/kg): %8.2f   %8.2f   %8.2f   %s\n', ...
    baseline.total_dose, optimal_schedule.total_dose, config.toxicity.Dtot_limit, ...
    status_str(analysis.toxicity_compliance.Dtot_status));

fprintf('\n=== TUMOR BURDEN ANALYSIS ===\n');
fprintf('No treatment:    %.2f\n', analysis.ctrl_burden);
fprintf('Paper schedule:  %.2f (%.1f%% reduction vs no treatment)\n', ...
    baseline.tumor_burden, analysis.baseline_reduction_pct);
fprintf('Optimal schedule: %.2f (%.1f%% reduction vs no treatment)\n', ...
    optimal_schedule.tumor_burden, analysis.optimal_reduction_pct);
fprintf('Improvement:     %.1f%% better tumor suppression than paper\n', ...
    analysis.improvement_pct);

end


function s = status_str(pass)
% Helper function to generate status string
if pass
    s = 'PASS';
else
    s = 'FAIL';
end
end
