function visualize_results(theta_hat, optimal_schedule, baseline, data, config, analysis)
% VISUALIZE_RESULTS Generate comprehensive result plots
%
% Creates three-panel figure showing:
%   1. Stage 1 model fit to experimental data
%   2. Comparison of dosing schedules
%   3. Tumor burden bar chart
%
% Inputs:
%   theta_hat        - Calibrated parameters
%   optimal_schedule - Optimal dosing schedule
%   baseline         - Baseline schedule metrics
%   data             - Experimental data
%   config           - Configuration
%   analysis         - Results analysis

% Close existing figures
close all;

% Create main figure
fig = figure('Position', [100, 100, 1400, 500], 'Color', 'w');
set(fig, 'Name', 'Bayesian Optimization Results', 'NumberTitle', 'off');

%% Panel 1: Stage 1 Model Fit
subplot(1, 3, 1);
hold on; grid on; box on;

% Plot experimental data
plot(data.t_data, data.V_ctrl_data, 'ko-', ...
    'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', 'k', ...
    'DisplayName', 'Control (no treatment)');
plot(data.t_data, data.V_trt_data, 'bs-', ...
    'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', 'b', ...
    'DisplayName', 'Treated (data)');

% Plot fitted model
plot(baseline.t_sim, baseline.V_sim, 'r--', ...
    'LineWidth', 3, 'DisplayName', 'Fitted model');

% Mark dose times
for i = 1:length(baseline.dose_times)
    xline(baseline.dose_times(i), 'g:', 'LineWidth', 2, 'Alpha', 0.6);
end

xlabel('Time (days)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Tumor Volume', 'FontSize', 12, 'FontWeight', 'bold');
title('Stage 1: Model Calibration', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 10);
set(gca, 'FontSize', 11);

%% Panel 2: Schedule Comparison
subplot(1, 3, 2);
hold on; grid on; box on;

% Plot trajectories
plot(analysis.t_ctrl, analysis.V_ctrl, 'k-', ...
    'LineWidth', 2.5, 'DisplayName', 'No treatment');
plot(baseline.t_sim, baseline.V_sim, 'b--', ...
    'LineWidth', 2.5, 'DisplayName', 'Paper schedule');
plot(optimal_schedule.t_sim, optimal_schedule.V_sim, 'r-', ...
    'LineWidth', 2.5, 'DisplayName', 'Optimized schedule');

% Mark baseline dose times
for i = 1:length(baseline.dose_times)
    xline(baseline.dose_times(i), 'b:', 'LineWidth', 1.5, 'Alpha', 0.5);
end

% Mark optimal dose times
for i = 1:length(optimal_schedule.dose_times)
    xline(optimal_schedule.dose_times(i), 'r:', 'LineWidth', 1.5, 'Alpha', 0.8);
end

xlabel('Time (days)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Tumor Volume', 'FontSize', 12, 'FontWeight', 'bold');
title('Stage 2: Schedule Optimization', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 10);
set(gca, 'FontSize', 11);

%% Panel 3: Tumor Burden Comparison
subplot(1, 3, 3);

bar_data = [analysis.ctrl_burden, baseline.tumor_burden, optimal_schedule.tumor_burden];
b = bar(bar_data, 'FaceColor', 'flat');

% Color bars
b.CData(1,:) = [0.3 0.3 0.3];  % Gray for control
b.CData(2,:) = [0.2 0.4 0.8];  % Blue for baseline
b.CData(3,:) = [0.8 0.2 0.2];  % Red for optimal

set(gca, 'XTickLabel', {'No Treatment', 'Paper', 'Optimized'});
ylabel('Tumor Burden (AUC)', 'FontSize', 12, 'FontWeight', 'bold');
title('Tumor Burden Comparison', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 11);

% Add value labels on bars
for i = 1:length(bar_data)
    text(i, bar_data(i), sprintf('%.1f', bar_data(i)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 11, 'FontWeight', 'bold');
end

% Force display
drawnow;
shg;

fprintf('Visualization complete.\n');

end
