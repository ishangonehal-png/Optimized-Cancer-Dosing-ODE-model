function data = load_tumor_data()
% LOAD_TUMOR_DATA Load experimental tumor growth data
%
% Returns:
%   data - Struct containing:
%       .t_data         : Time points (days)
%       .V_ctrl_data    : Control group tumor volumes
%       .V_trt_data     : Treated group tumor volumes
%       .dose_times     : Paper dosing schedule times (days)
%       .dose_amounts   : Paper dosing schedule amounts (mg/kg)
%       .V0             : Initial tumor volume
%       .T_horizon      : Study duration (days)
%
% Data source: Preclinical xenograft study with chemotherapy treatment

% Time points (days from treatment start)
data.t_data = [9, 11, 13, 15, 17, 19, 23, 28, 31];

% Control group tumor volumes (no treatment)
data.V_ctrl_data = [0.65, 1.21, 1.96, 3.59, 4.56, 6.23, 9.77, 13.52, 17.13];

% Treated group tumor volumes (paper's standard dosing)
data.V_trt_data = [0.65, 1.21, 1.96, 2.63, 2.52, 2.03, 2.28, 4.02, 6.26];

% Paper's dosing schedule (baseline/reference treatment)
data.dose_times = [8, 12, 16];      % Days when doses administered
data.dose_amounts = [30, 30, 30];   % Dose amounts (mg/kg)

% Derived parameters
data.V0 = data.V_trt_data(1);       % Initial volume
data.T_horizon = data.t_data(end);  % Study duration

% Paper's maximum safe dose (established safety limit)
data.D_paper = 30;  % mg/kg per dose

fprintf('Loaded data: %d time points, %d doses\n', ...
    length(data.t_data), length(data.dose_times));
fprintf('Study duration: %.0f days\n', data.T_horizon);
fprintf('Baseline schedule: %.0f mg/kg every %.0f days\n', ...
    data.D_paper, mean(diff(data.dose_times)));

end
