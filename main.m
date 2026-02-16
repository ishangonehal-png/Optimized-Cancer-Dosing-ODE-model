%% Two-Stage Bayesian Optimization for Cancer Chemotherapy Scheduling
% Main driver script
%
% This project implements a two-stage Bayesian optimization framework for
% optimizing cancer chemotherapy dosing schedules with toxicity constraints.
%
% Stage 1: Calibrate biological parameters from preclinical tumor data
% Stage 2: Optimize dosing schedule while respecting safety constraints
%
% USAGE:
%   1. Ensure all project files are in MATLAB path
%   2. Run this script: main.m
%   3. Results displayed in Command Window with visualization plots
%
% Author: Ishan
% Date: 2024

clear; clc; close all;

%% Load experimental data
fprintf('=== Loading experimental data ===\n');
data = load_tumor_data();

%% Configure optimization parameters
fprintf('\n=== Configuring optimization parameters ===\n');
config = setup_optimization_config(data);

%% STAGE 1: Biological Parameter Calibration
fprintf('\n=== STAGE 1: Calibrating biological parameters ===\n');
fprintf('Fitting Gompertz tumor growth model to treated data...\n\n');

[theta_hat, results1] = calibrate_biology(data, config);

% Display calibrated parameters
fprintf('\n=== Calibrated Parameters ===\n');
fprintf('a (growth rate): %.4f /day\n', theta_hat.a);
fprintf('K (carrying capacity): %.4f\n', theta_hat.K);
fprintf('k_kill (drug effectiveness): %.6f\n', theta_hat.k_kill);
fprintf('k_e (clearance rate): %.4f /day\n', theta_hat.k_e);
fprintf('Final fit error: %.4f\n', results1.MinObjective);

%% Compute baseline toxicity metrics
fprintf('\n=== Computing baseline toxicity metrics ===\n');
baseline = compute_baseline_metrics(theta_hat, data, config);

% Configure toxicity constraints based on paper safety data
config.toxicity = configure_toxicity_constraints(baseline, config);

%% STAGE 2: Dosing Schedule Optimization
fprintf('\n=== STAGE 2: Optimizing dosing schedule ===\n');
fprintf('Searching for optimal schedule with toxicity constraints...\n\n');

[optimal_schedule, results2] = optimize_dosing_schedule(theta_hat, ...
    data, config, baseline);

%% Analyze and compare results
fprintf('\n=== Analyzing results ===\n');
analysis = analyze_results(theta_hat, optimal_schedule, baseline, data, config);

%% Generate visualizations
fprintf('\n=== Generating plots ===\n');
visualize_results(theta_hat, optimal_schedule, baseline, data, config, analysis);

%% Display summary
display_summary(optimal_schedule, baseline, analysis, config);

fprintf('\n=== OPTIMIZATION COMPLETE ===\n');
fprintf('All results saved and displayed.\n');
