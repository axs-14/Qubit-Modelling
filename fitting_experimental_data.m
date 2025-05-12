% Clear workspace
clear; clc; close all;

% Load Frequency Modulated (FM) Data
fm_filename = 'FM_data.csv'; 
fm_data = readmatrix(fm_filename);
fm_data(1:2, :) = [];  % Remove first two rows

% Load Amplitude Modulated (AM) Data
am_filename = 'AM_data.csv'; 
am_data = readmatrix(am_filename);
am_data(1:2, :) = [];  % Remove first two rows

% Ensure data has enough columns
if size(fm_data, 2) < 84 || size(am_data, 2) < 84
   error('CSV file does not have at least 84 columns. Check the format.');
end

% Extract Magnetic Field
B_field_FM = fm_data(:,1); 
B_field_AM = am_data(:,1); 

% Keep only entries where 1.3205 ≤ B-field ≤ 1.3235
valid_idx_FM = (B_field_FM >= 1.3205) & (B_field_FM <= 1.3235);
valid_idx_AM = (B_field_AM >= 1.3205) & (B_field_AM <= 1.3235);
B_field_FM = B_field_FM(valid_idx_FM);
B_field_AM = B_field_AM(valid_idx_AM);

% Extract X-values and Background from Columns 82 and 84
X_FM_avg = -1*(fm_data(valid_idx_FM, 81) - fm_data(valid_idx_FM, 83)); 
X_AM_avg = am_data(valid_idx_AM, 81) - am_data(valid_idx_AM, 83); 

% Zero the FM Data by Subtracting the Mean
X_FM_avg = X_FM_avg - mean(X_FM_avg);

% --- Background Removal for AM using Linear Fit ---
coeffs = polyfit(B_field_AM, X_AM_avg, 1); % Fit linear model y = mx + c
linear_fit = polyval(coeffs, B_field_AM); % Evaluate fitted line
X_AM_corrected = X_AM_avg - linear_fit; % Subtract linear background

% --- EasySpin EPR Simulation with Different Broadening ---
% Simulation 1: Smaller Linewidth (Sharper Peaks) for AM
Sys1.S = 1/2;                        
Sys1.g = [1.9985 1.9985 1.9985];     
Sys1.Nucs = '29Si,31P';              
Sys1.A = [4 117.5];                  
Sys1.lwpp = 0.16;                     

% Simulation 2: Larger Linewidth (Broader Peaks) for FM
Sys2 = Sys1;                         
Sys2.lwpp = 0.36;                     

% Experimental Parameters (same for both simulations)
Exp.mwFreq = 37.0735;                
Exp.Range = [1.3205 1.324] * 1e3;    
Exp.Harmonic = 0;                    

% Simulate Spectrum for both systems
[B_field_EPR1, EPR_spectrum1] = pepper(Sys1, Exp); 
[B_field_EPR2, EPR_spectrum2] = pepper(Sys2, Exp); 

% Compute First Derivative for FM Overlay using gradient
EPR_derivative = gradient(EPR_spectrum2, mean(diff(B_field_EPR2))); 
B_field_derivative = B_field_EPR2 / 1e3; 

% Normalize AM spectrum
EPR_spectrum1 = EPR_spectrum1 / max(abs(EPR_spectrum1));  
EPR_spectrum1 = EPR_spectrum1 * max(abs(X_AM_corrected));  

% Normalize FM derivative
EPR_derivative = EPR_derivative / max(abs(EPR_derivative));  
EPR_derivative = EPR_derivative * max(abs(X_FM_avg));  

% --- Find Global Peaks ---
[AM_peak_value, AM_peak_idx] = max(X_AM_corrected);
AM_peak_B_field = B_field_AM(AM_peak_idx);
[EPR_peak_value, EPR_peak_idx] = max(EPR_spectrum1);
EPR_peak_B_field = B_field_EPR1(EPR_peak_idx) / 1e3;

shift_AM = EPR_peak_B_field - AM_peak_B_field;
B_field_AM_shifted = B_field_AM + shift_AM;

[FM_peak_value, FM_peak_idx] = max(X_FM_avg);
FM_peak_B_field = B_field_FM(FM_peak_idx);
[EPR_deriv_peak_value, EPR_deriv_peak_idx] = max(EPR_derivative);
EPR_deriv_peak_B_field = B_field_derivative(EPR_deriv_peak_idx);

shift_FM = EPR_deriv_peak_B_field - FM_peak_B_field;
B_field_FM_shifted = B_field_FM + shift_FM;

% --- Linewidth Optimization ---
lwpp_values = 0.15:0.01:0.4;
best_lwpp_AM = NaN;
best_lwpp_FM = NaN;
min_MSE_AM = Inf;
min_MSE_FM = Inf;

compute_MSE = @(exp_data, sim_data, exp_field, sim_field) ...
   sum((interp1(sim_field, sim_data, exp_field, 'linear', 'extrap') - exp_data).^2) / length(exp_data);

for lwpp = lwpp_values
   Sys1.lwpp = lwpp;
   [B_field_EPR1, EPR_spectrum1] = pepper(Sys1, Exp);
   EPR_spectrum1 = EPR_spectrum1 / max(abs(EPR_spectrum1));
   EPR_spectrum1 = EPR_spectrum1 * max(abs(X_AM_corrected));
   MSE_AM = compute_MSE(X_AM_corrected, EPR_spectrum1, B_field_AM_shifted, B_field_EPR1 / 1e3);
   if MSE_AM < min_MSE_AM
       min_MSE_AM = MSE_AM;
       best_lwpp_AM = lwpp;
   end

   Sys2.lwpp = lwpp;
   [B_field_EPR2, EPR_spectrum2] = pepper(Sys2, Exp);
   EPR_spectrum2 = EPR_spectrum2 / max(abs(EPR_spectrum2));
   EPR_spectrum2 = EPR_spectrum2 * max(abs(X_AM_corrected));
   EPR_derivative = gradient(EPR_spectrum2, mean(diff(B_field_EPR2)));
   MSE_FM = compute_MSE(X_FM_avg, EPR_derivative, B_field_FM_shifted, B_field_EPR2 / 1e3);
   if MSE_FM < min_MSE_FM
       min_MSE_FM = MSE_FM;
       best_lwpp_FM = lwpp;
   end
end

fprintf('Best linewidth for AM: %.2f\n', best_lwpp_AM);
fprintf('Best linewidth for FM: %.2f\n', best_lwpp_FM);

% --- Final Simulations with Optimal Linewidths ---
Sys1.lwpp = best_lwpp_AM;
[B_field_EPR1, EPR_spectrum1] = pepper(Sys1, Exp);
EPR_spectrum1 = EPR_spectrum1 / max(abs(EPR_spectrum1));
EPR_spectrum1 = EPR_spectrum1 * max(abs(X_AM_corrected));

Sys2.lwpp = best_lwpp_FM;
[B_field_EPR2, EPR_spectrum2] = pepper(Sys2, Exp);
EPR_spectrum2 = EPR_spectrum2 / max(abs(EPR_spectrum2));
EPR_spectrum2 = EPR_spectrum2 * max(abs(X_AM_corrected));
EPR_derivative = gradient(EPR_spectrum2, mean(diff(B_field_EPR2)));
B_field_derivative = B_field_EPR2 / 1e3;
EPR_derivative = EPR_derivative / max(abs(EPR_derivative));
EPR_derivative = EPR_derivative * max(abs(X_FM_avg));

% --- Compute reduced chi-square for AM ---
p = 1;  % Number of parameters (lwpp)
residuals_AM = X_AM_corrected - interp1(B_field_EPR1 / 1e3, EPR_spectrum1, B_field_AM_shifted, 'linear', 'extrap');
reduced_chi2_AM = sum(residuals_AM.^2) / (length(X_AM_corrected) - p);

% --- Compute reduced chi-square for FM ---
residuals_FM = X_FM_avg - interp1(B_field_derivative, EPR_derivative, B_field_FM_shifted, 'linear', 'extrap');
reduced_chi2_FM = sum(residuals_FM.^2) / (length(X_FM_avg) - p);

% Display reduced chi-squared values
fprintf('Reduced chi-squared for AM: %.4f\n', reduced_chi2_AM);
fprintf('Reduced chi-squared for FM: %.4f\n', reduced_chi2_FM);

% --- Plot AM Corrected Data with Simulated Spectrum ---
figure;
plot(B_field_AM_shifted, X_AM_corrected, 'k-', 'LineWidth', 1.5); hold on;
plot(B_field_EPR1 / 1e3, EPR_spectrum1, '--', 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5); % dark blue dashed
xlabel('Magnetic Field (T)');
ylabel('Corrected X-Averaged Signal (AM)');
title('AM Signal vs Simulated EPR (Best Fit)');
legend('AM Experimental', 'Simulated EPR', 'Location', 'Best');
grid on;


% --- Plot FM Data with Simulated Derivative ---
figure;
plot(B_field_FM_shifted, X_FM_avg, 'k-', 'LineWidth', 1.5); hold on;
plot(B_field_derivative, EPR_derivative, '--', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5); % dark red dashed
xlabel('Magnetic Field (T)');
ylabel('Zeroed X-Averaged Signal (FM)');
title('FM Signal vs Simulated EPR Derivative (Best Fit)');
legend('FM Experimental', 'Simulated Derivative', 'Location', 'Best');
grid on;