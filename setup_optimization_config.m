function config = setup_optimization_config(data)
% SETUP_OPTIMIZATION_CONFIG Configure optimization parameters
%
% Inputs:
%   data - Struct containing experimental data
%
% Returns:
%   config - Struct containing optimization configuration:
%       .param_ranges : Parameter search ranges for Stage 1
%       .stage1       : Stage 1 Bayesian optimization settings
%       .stage2       : Stage 2 optimization settings
%       .N_doses      : Number of doses to optimize

%% Parameter ranges for Stage 1 calibration

% Growth rate a (1/day)
% Typical range for cancer cell doubling time: 3-10 days
config.param_ranges.a_min = 0.05;
config.param_ranges.a_max = 0.25;

% Carrying capacity K (same units as tumor volume)
V0 = data.V0;
V_max = max(data.V_ctrl_data);
config.param_ranges.K_min = 1.5 * V_max;
config.param_ranges.K_max = 100 * V0;

% Drug kill coefficient k_kill (drug effectiveness)
% Controls how much tumor shrinks per unit drug concentration
config.param_ranges.k_kill_min = 0.001;
config.param_ranges.k_kill_max = 0.2;

% Drug clearance rate k_e (1/day)
% Typical biological half-life: 0.5-7 days -> k_e = ln(2)/t_half
config.param_ranges.k_e_min = 0.1;
config.param_ranges.k_e_max = 1.5;

%% Stage 1: Biology Calibration Settings

config.stage1.max_evals = 100;  % Number of Bayesian optimization iterations
config.stage1.acquisition_fn = 'expected-improvement-plus';
config.stage1.verbose = 1;      % Display progress

%% Stage 2: Dosing Optimization Settings

config.stage2.max_evals = 40;
config.stage2.acquisition_fn = 'expected-improvement-plus';
config.stage2.verbose = 1;

% Number of doses (match paper for fair comparison)
config.N_doses = 3;

% Decision variable ranges
config.stage2.t_start_min = data.t_data(1);
config.stage2.t_start_max = data.T_horizon - (config.N_doses - 1) * 2;

% Dosing interval (days between doses)
% Paper used 4 days; allow variation
config.stage2.Delta_min = 3;   % More frequent dosing
config.stage2.Delta_max = 7;   % Less frequent dosing

% Dose amount (mg/kg)
% Paper established 30 mg/kg as maximum safe dose
config.stage2.D_min = 0.67 * data.D_paper;  % 20 mg/kg
config.stage2.D_max = 1.17 * data.D_paper;  % 35 mg/kg

fprintf('Configuration complete.\n');
fprintf('Stage 1: %d evaluations, %d parameters\n', ...
    config.stage1.max_evals, 4);
fprintf('Stage 2: %d evaluations, %d decision variables\n', ...
    config.stage2.max_evals, 3);

end
