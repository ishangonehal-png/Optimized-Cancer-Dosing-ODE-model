function toxicity = configure_toxicity_constraints(baseline, config)
% CONFIGURE_TOXICITY_CONSTRAINTS Set up toxicity constraint parameters
%
% Establishes hard limits and soft penalty weights based on paper's
% established safety data.
%
% Inputs:
%   baseline - Baseline metrics from paper's schedule
%   config   - Optimization configuration
%
% Returns:
%   toxicity - Struct containing:
%       .Cmax_limit   : Maximum allowed peak concentration
%       .AUC_limit    : Maximum allowed cumulative drug exposure
%       .Dtot_limit   : Maximum allowed total dose
%       .lambda_auc   : Penalty weight for AUC (soft constraint)
%       .lambda_peak  : Penalty weight for Cmax (soft constraint)

fprintf('\n=== Configuring toxicity constraints ===\n');
fprintf('Based on paper safety data (30 mg/kg per dose, q4d × 3)\n\n');

%% Hard limits (multipliers of baseline)
% Paper's regimen represents the MAXIMUM TOLERATED dosing

% CONSERVATIVE settings:
% Cmax_limit_mult = 1.05;   % allow 5% higher peak
% AUC_limit_mult = 1.10;    % allow 10% higher total exposure
% Dtot_limit_mult = 1.00;   % never exceed total drug

% MODERATE settings (uncomment for more flexibility):
Cmax_limit_mult = 1.10;   % allow 10% higher peak
AUC_limit_mult = 1.05;    % allow 5% higher total exposure
Dtot_limit_mult = 1.05;   % allow 5% more total drug

% Compute actual limits
toxicity.Cmax_limit = Cmax_limit_mult * baseline.Cmax;
toxicity.AUC_limit = AUC_limit_mult * baseline.AUC;
toxicity.Dtot_limit = Dtot_limit_mult * baseline.total_dose;

fprintf('Hard limits (constraints):\n');
fprintf('  Max Cmax: %.2f (%.0f%% of baseline)\n', ...
    toxicity.Cmax_limit, Cmax_limit_mult * 100);
fprintf('  Max AUC: %.2f (%.0f%% of baseline)\n', ...
    toxicity.AUC_limit, AUC_limit_mult * 100);
fprintf('  Max total dose: %.2f mg/kg (%.0f%% of baseline)\n', ...
    toxicity.Dtot_limit, Dtot_limit_mult * 100);

%% Soft penalty weights
% Among safe (feasible) schedules, prefer ones with lower toxicity

% Preference parameters (interpretable tradeoffs)
p_auc = 0.70;   % willing to trade ~10% tumor burden for lower cumulative exposure
p_peak = 0.05;  % willing to trade ~5% tumor burden to avoid concentration spikes

% Scale to make penalty terms comparable to tumor burden
toxicity.lambda_auc = p_auc * (baseline.tumor_burden / baseline.AUC);
toxicity.lambda_peak = p_peak * (baseline.tumor_burden / baseline.Cmax);

fprintf('\nSoft penalties (preferences among feasible schedules):\n');
fprintf('  Preference weight p_auc: %.2f\n', p_auc);
fprintf('  Preference weight p_peak: %.2f\n', p_peak);
fprintf('  Scaled lambda_auc: %.4f\n', toxicity.lambda_auc);
fprintf('  Scaled lambda_peak: %.4f\n', toxicity.lambda_peak);

end
