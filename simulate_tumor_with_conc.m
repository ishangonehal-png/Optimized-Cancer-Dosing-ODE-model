function [t, V, C] = simulate_tumor_with_conc(a, K, k_kill, k_e, V0, t_start, t_end, dose_times, dose_amounts)
% SIMULATE_TUMOR_WITH_CONC Simulate Gompertz tumor growth with drug PK/PD
%
% Integrates coupled ODEs for:
%   - Tumor volume (Gompertz growth + drug-induced kill)
%   - Drug concentration (first-order elimination + instantaneous doses)
%
% Inputs:
%   a            - Tumor growth rate (1/day)
%   K            - Carrying capacity (volume units)
%   k_kill       - Drug kill coefficient
%   k_e          - Drug elimination rate (1/day)
%   V0           - Initial tumor volume
%   t_start      - Simulation start time (days)
%   t_end        - Simulation end time (days)
%   dose_times   - Vector of dosing times (days)
%   dose_amounts - Vector of dose amounts (mg/kg)
%
% Returns:
%   t - Time vector (days)
%   V - Tumor volume trajectory
%   C - Drug concentration trajectory

% ODE function handle
ode_func = @(t, y) tumor_ode(t, y, a, K, k_kill, k_e);

% Handle case with no doses (control group)
if isempty(dose_times)
    tspan = linspace(t_start, t_end, 200);
    y0 = [V0; 0];  % [volume; concentration]
    options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
    [t, y] = ode45(ode_func, tspan, y0, options);
    V = y(:, 1);
    C = y(:, 2);
    return;
end

% Filter dose times within simulation window
valid_doses = dose_times >= t_start & dose_times <= t_end;
dose_times = dose_times(valid_doses);
dose_amounts = dose_amounts(valid_doses);

if isempty(dose_times)
    % No valid doses in this time window
    tspan = linspace(t_start, t_end, 200);
    y0 = [V0; 0];
    options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
    [t, y] = ode45(ode_func, tspan, y0, options);
    V = y(:, 1);
    C = y(:, 2);
    return;
end

% Simulate segment-by-segment between doses
all_times = [t_start, dose_times, t_end];
t = [];
V = [];
C_current = 0;  % initial concentration

for i = 1:length(all_times)-1
    % Solve from current time to next event
    tspan = linspace(all_times(i), all_times(i+1), 50);
    
    if i == 1
        y0 = [V0; C_current];
    else
        y0 = [V(end); C_current];
    end
    
    options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
    [t_seg, y_seg] = ode45(ode_func, tspan, y0, options);
    
    % Append results (avoid duplicates)
    if i > 1
        t = [t; t_seg(2:end)];
        V = [V; y_seg(2:end, 1)];
        C = [C; y_seg(2:end, 2)];
    else
        t = t_seg;
        V = y_seg(:, 1);
        C = y_seg(:, 2);
    end
    
    % Update concentration with dose (instantaneous jump)
    C_current = y_seg(end, 2);
    if i < length(all_times) - 1
        % Apply dose at next time point
        dose_idx = find(abs(dose_times - all_times(i+1)) < 1e-6, 1);
        if ~isempty(dose_idx)
            C_current = C_current + dose_amounts(dose_idx);
        end
    end
end

end


function dydt = tumor_ode(t, y, a, K, k_kill, k_e)
% TUMOR_ODE Coupled ODE system for tumor-drug dynamics
%
% System:
%   dV/dt = a*V*log(K/V) - k_kill*C*V  (Gompertz growth + drug kill)
%   dC/dt = -k_e*C                      (first-order elimination)

V = y(1);  % tumor volume
C = y(2);  % drug concentration

% Numerical safeguards
if V <= 0
    V = 1e-10;
end
if V >= K
    V = K - 1e-10;
end

% Tumor dynamics
dVdt = a * V * log(K / V) - k_kill * C * V;

% Drug elimination
dCdt = -k_e * C;

dydt = [dVdt; dCdt];

end
