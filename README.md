# Two-Stage Bayesian Optimization for Cancer Chemotherapy Scheduling

A computational framework for optimizing cancer chemotherapy dosing schedules using Bayesian optimization with safety constraints derived from preclinical data.

## Overview

This project implements a **two-stage optimization approach** to find improved chemotherapy dosing schedules that:
- **Maximize tumor suppression** (reduce tumor burden)
- **Respect safety constraints** based on established maximum tolerated dose (MTD)
- **Balance efficacy and toxicity** through multi-objective optimization

### Key Features

- **Mechanistic tumor growth model**: Gompertz dynamics with drug-induced cytotoxicity
- **Pharmacokinetic modeling**: First-order drug elimination with instantaneous dosing
- **Bayesian optimization**: Efficient search through high-dimensional parameter spaces
- **Safety-constrained optimization**: Hard limits on peak concentration, cumulative exposure, and total dose
- **Comprehensive analysis**: Automated comparison against baseline schedules

## Scientific Background

### Two-Stage Optimization Framework

**Stage 1: Biological Parameter Calibration**
- Fits Gompertz tumor growth model to experimental data
- Calibrates four key parameters using Bayesian optimization:
  - `a`: Tumor growth rate (1/day)
  - `K`: Carrying capacity (volume units)
  - `k_kill`: Drug kill coefficient
  - `k_e`: Drug clearance rate (1/day)

**Stage 2: Dosing Schedule Optimization**
- Optimizes three dosing parameters:
  - `t_start`: Treatment start time
  - `Delta`: Inter-dose interval
  - `D`: Dose amount (mg/kg)
- Subject to toxicity constraints:
  - Peak concentration (Cmax) ≤ limit
  - Cumulative exposure (AUC) ≤ limit
  - Total dose ≤ limit

### Mathematical Model

**Tumor-Drug Dynamics** (coupled ODEs):
```
dV/dt = a·V·ln(K/V) - k_kill·C·V    (Gompertz growth + drug kill)
dC/dt = -k_e·C                       (first-order elimination)
```

**Objective Function** (Stage 2):
```
minimize: tumor_burden + λ_AUC·AUC + λ_peak·Cmax
subject to:
  - Cmax ≤ Cmax_limit
  - AUC ≤ AUC_limit
  - Total_dose ≤ Dtot_limit
```

## Project Structure

```
tumor_bayesopt_project/
├── main.m                              # Main driver script
├── load_tumor_data.m                   # Data loading
├── setup_optimization_config.m         # Configuration
├── calibrate_biology.m                 # Stage 1 optimization
├── compute_baseline_metrics.m          # Baseline calculation
├── configure_toxicity_constraints.m    # Safety constraint setup
├── optimize_dosing_schedule.m          # Stage 2 optimization
├── simulate_tumor_with_conc.m          # ODE simulation
├── analyze_results.m                   # Results analysis
├── visualize_results.m                 # Plotting
├── display_summary.m                   # Summary output
└── README.md                           # This file
```

## Installation & Usage

### Requirements
- MATLAB R2020a or later
- Optimization Toolbox (for `bayesopt`)
- Statistics and Machine Learning Toolbox

### Quick Start

1. **Clone or download** this repository
2. **Add to MATLAB path**:
   ```matlab
   addpath('path/to/tumor_bayesopt_project')
   ```
3. **Run optimization**:
   ```matlab
   main
   ```

### Expected Runtime
- Stage 1: ~3-5 minutes (100 Bayesian optimization iterations)
- Stage 2: ~2-3 minutes (40 iterations)
- **Total**: 5-10 minutes on standard hardware

## Results

### Typical Outcomes

The optimization typically achieves:
- **4-10% improvement** in tumor suppression vs. baseline schedule
- **20-35% reduction** in total drug exposure
- **All safety constraints satisfied** (Cmax, AUC, total dose within limits)

### Output

The framework generates:

1. **Console output**:
   - Calibrated parameter values
   - Optimal dosing schedule
   - Comparative metrics (efficacy & toxicity)
   - Safety compliance status

2. **Visualizations** (3-panel figure):
   - Stage 1 model fit to data
   - Comparison of dosing schedules (baseline vs. optimized)
   - Tumor burden bar chart

3. **Numerical results**:
   - All metrics stored in MATLAB workspace
   - Can be exported for further analysis

## Customization

### Adjusting Safety Constraints

Edit `configure_toxicity_constraints.m` to modify constraint severity:

```matlab
% CONSERVATIVE (strict safety margins)
Cmax_limit_mult = 1.05;   % allow 5% higher peak
AUC_limit_mult = 1.10;    % allow 10% higher exposure

% MODERATE (balanced)
Cmax_limit_mult = 1.10;   % allow 10% higher peak
AUC_limit_mult = 1.15;    % allow 15% higher exposure
```

### Changing Optimization Settings

Modify `setup_optimization_config.m`:

```matlab
% Increase optimization budget for better solutions
config.stage1.max_evals = 150;  % default: 100
config.stage2.max_evals = 60;   % default: 40

% Allow different number of doses
config.N_doses = 4;  % default: 3
```

### Using Different Data

Replace data in `load_tumor_data.m` with your own:
- Time points (`t_data`)
- Control tumor volumes (`V_ctrl_data`)
- Treated tumor volumes (`V_trt_data`)
- Reference dosing schedule (`dose_times`, `dose_amounts`)

## Algorithm Details

### Bayesian Optimization

Uses MATLAB's `bayesopt` with:
- **Acquisition function**: Expected improvement plus (EI+)
- **Surrogate model**: Gaussian process regression
- **Parameter transforms**: Log-scale for `k_kill` (improved sampling)

### Why Bayesian Optimization?

Traditional optimization methods (gradient descent, grid search) struggle with:
- **Expensive evaluations**: Each candidate schedule requires ODE integration
- **Non-convex landscape**: Multiple local minima
- **Noisy objectives**: Numerical integration introduces slight variance

Bayesian optimization excels because it:
- **Efficiently explores** parameter space with few evaluations
- **Balances exploration vs. exploitation** intelligently
- **Handles black-box objectives** without gradient information

## Biological Interpretation

### What Do the Parameters Mean?

- **`a` (growth rate)**: How fast tumor grows when small
  - Higher values → faster initial growth
  - Typical range: 0.05-0.25 /day (doubling time: 3-14 days)

- **`K` (carrying capacity)**: Maximum sustainable tumor size
  - Determined by nutrient/oxygen availability
  - Controls growth saturation

- **`k_kill` (drug effectiveness)**: How much tumor shrinks per unit drug
  - Drug-specific, dose-dependent
  - Higher values → more potent drug

- **`k_e` (clearance rate)**: How fast drug is eliminated
  - Determines drug half-life: t_half = ln(2)/k_e
  - Typical range: 0.5-7 days half-life

### Clinical Translation

This framework demonstrates how **computational optimization** can:
1. Identify **non-obvious dosing strategies** (e.g., front-loading, delayed dosing)
2. **Quantify tradeoffs** between efficacy and toxicity
3. **Reduce drug exposure** while maintaining or improving outcomes
4. **Accelerate preclinical→clinical translation** by exploring larger design space

## Limitations

- **Simplified pharmacokinetics**: Single-compartment model, linear elimination
- **No resistance modeling**: Assumes constant drug sensitivity
- **Fixed dose number**: Optimizes timing/amount, not number of doses
- **Preclinical data only**: Requires clinical validation before use

## Future Extensions

Potential improvements:
- [ ] Multi-compartment PK model (tissue distribution)
- [ ] Adaptive dosing (adjust based on tumor response)
- [ ] Resistance emergence (acquired drug resistance)
- [ ] Multi-drug optimization (combination therapy)
- [ ] Patient-specific calibration (personalized dosing)
- [ ] Uncertainty quantification (confidence intervals on predictions)

## Citation

If you use this code in your research, please cite:

```
[Your name], Two-Stage Bayesian Optimization for Cancer Chemotherapy 
Scheduling, GitHub repository, 2024. 
https://github.com/[yourusername]/tumor_bayesopt_project
```

## License

MIT License - feel free to use and modify for research or educational purposes.

## Contact

For questions or collaboration:
- Email: [ishangonehal@berkeley.edu]
- GitHub: [@ishangonehal-png](https://github.com/@ishangonehal-png)
---

**Disclaimer**: This is a research tool for computational exploration. It is NOT approved for clinical use. All dosing decisions should be made by qualified medical professionals following established clinical protocols.
