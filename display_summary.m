function display_summary(optimal_schedule, baseline, analysis, config)
% DISPLAY_SUMMARY Print comprehensive summary of optimization results
%
% Inputs:
%   optimal_schedule - Optimized dosing schedule
%   baseline         - Baseline schedule metrics
%   analysis         - Results analysis
%   config           - Configuration

fprintf('\n');
fprintf('========================================\n');
fprintf('   OPTIMIZATION SUMMARY\n');
fprintf('========================================\n');

%% Dosing Schedule
fprintf('\n--- OPTIMAL DOSING SCHEDULE ---\n');
fprintf('Start time:     %.1f days\n', optimal_schedule.t_start);
fprintf('Dose interval:  %.1f days\n', optimal_schedule.Delta);
fprintf('Dose amount:    %.1f mg/kg\n', optimal_schedule.D);
fprintf('Dose times:     [%.1f, %.1f, %.1f] days\n', ...
    optimal_schedule.dose_times);

%% Efficacy Comparison
fprintf('\n--- EFFICACY RESULTS ---\n');
fprintf('Tumor burden reduction (vs no treatment):\n');
fprintf('  Paper schedule:    %.1f%%\n', analysis.baseline_reduction_pct);
fprintf('  Optimal schedule:  %.1f%%\n', analysis.optimal_reduction_pct);
fprintf('  Improvement:       %.1f%% better suppression\n', analysis.improvement_pct);

%% Safety Compliance
fprintf('\n--- SAFETY COMPLIANCE ---\n');
fprintf('All toxicity constraints: %s\n', ...
    all_pass_str([analysis.toxicity_compliance.Cmax_status, ...
                  analysis.toxicity_compliance.AUC_status, ...
                  analysis.toxicity_compliance.Dtot_status]));

fprintf('\nConstraint utilization:\n');
fprintf('  Peak Cmax:    %.1f%% of limit\n', analysis.toxicity_compliance.Cmax_utilization);
fprintf('  Drug AUC:     %.1f%% of limit\n', analysis.toxicity_compliance.AUC_utilization);
fprintf('  Total dose:   %.1f%% of limit\n', analysis.toxicity_compliance.Dtot_utilization);

%% Toxicity Changes
fprintf('\n--- TOXICITY PROFILE CHANGES (vs baseline) ---\n');
fprintf('  Peak Cmax:    %+.1f%%\n', analysis.toxicity_changes.Cmax_pct);
fprintf('  Drug AUC:     %+.1f%%\n', analysis.toxicity_changes.AUC_pct);
fprintf('  Total dose:   %+.1f%%\n', analysis.toxicity_changes.Dtot_pct);

%% Key Findings
fprintf('\n--- KEY FINDINGS ---\n');
if analysis.improvement_pct > 5
    fprintf('✓ Significant improvement in tumor suppression\n');
else
    fprintf('○ Modest improvement in tumor suppression\n');
end

if all([analysis.toxicity_compliance.Cmax_status, ...
        analysis.toxicity_compliance.AUC_status, ...
        analysis.toxicity_compliance.Dtot_status])
    fprintf('✓ All safety constraints satisfied\n');
else
    fprintf('✗ Some safety constraints violated\n');
end

if analysis.toxicity_changes.AUC_pct < 0
    fprintf('✓ Reduced cumulative drug exposure\n');
else
    fprintf('○ Increased cumulative drug exposure\n');
end

fprintf('\n========================================\n\n');

end


function s = all_pass_str(status_array)
% Helper to generate overall pass/fail string
if all(status_array)
    s = 'ALL PASS ✓';
else
    s = 'SOME FAILURES ✗';
end
end
